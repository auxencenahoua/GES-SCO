CREATE TABLE IF NOT EXISTS app.teaching_assignment (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  staff_id uuid NOT NULL REFERENCES app.staff(id) ON DELETE RESTRICT,
  class_id uuid NOT NULL REFERENCES app.class(id) ON DELETE RESTRICT,
  subject_id uuid NOT NULL REFERENCES app.subject(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, staff_id, class_id, subject_id)
);

CREATE TABLE IF NOT EXISTS app.schedule_slot (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  class_id uuid NOT NULL REFERENCES app.class(id) ON DELETE RESTRICT,
  subject_id uuid NOT NULL REFERENCES app.subject(id) ON DELETE RESTRICT,
  staff_id uuid REFERENCES app.staff(id) ON DELETE RESTRICT,
  weekday smallint NOT NULL CHECK (weekday BETWEEN 1 AND 7),
  starts_at time NOT NULL,
  ends_at time NOT NULL,
  room text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (ends_at > starts_at)
);

CREATE TABLE IF NOT EXISTS app.attendance_record (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  student_id uuid NOT NULL REFERENCES app.student(id) ON DELETE RESTRICT,
  class_id uuid NOT NULL REFERENCES app.class(id) ON DELETE RESTRICT,
  occurred_on date NOT NULL,
  status text NOT NULL CHECK (status IN ('present', 'absent', 'late', 'excused')),
  recorded_by_staff_id uuid REFERENCES app.staff(id) ON DELETE RESTRICT,
  reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, student_id, class_id, occurred_on)
);

CREATE TABLE IF NOT EXISTS app.assessment (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  class_id uuid NOT NULL REFERENCES app.class(id) ON DELETE RESTRICT,
  subject_id uuid NOT NULL REFERENCES app.subject(id) ON DELETE RESTRICT,
  title text NOT NULL CHECK (char_length(title) BETWEEN 2 AND 200),
  occurred_on date NOT NULL,
  maximum_score numeric(7,2) NOT NULL CHECK (maximum_score > 0),
  coefficient numeric(5,2) NOT NULL DEFAULT 1 CHECK (coefficient > 0),
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'locked')),
  created_by_staff_id uuid REFERENCES app.staff(id) ON DELETE RESTRICT,
  published_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS app.grade (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenant(id) ON DELETE RESTRICT,
  assessment_id uuid NOT NULL REFERENCES app.assessment(id) ON DELETE RESTRICT,
  student_id uuid NOT NULL REFERENCES app.student(id) ON DELETE RESTRICT,
  score numeric(7,2) NOT NULL CHECK (score >= 0),
  comment text,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'locked')),
  recorded_by_staff_id uuid REFERENCES app.staff(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, assessment_id, student_id)
);

CREATE OR REPLACE FUNCTION app.enforce_pedagogy_tenant_consistency()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE related_tenant uuid;
BEGIN
  IF TG_TABLE_NAME IN ('teaching_assignment', 'schedule_slot') AND NEW.staff_id IS NOT NULL THEN
    SELECT tenant_id INTO related_tenant FROM app.staff WHERE id = NEW.staff_id;
    IF related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'staff tenant mismatch'; END IF;
  ELSIF TG_TABLE_NAME IN ('attendance_record', 'grade') AND NEW.recorded_by_staff_id IS NOT NULL THEN
    SELECT tenant_id INTO related_tenant FROM app.staff WHERE id = NEW.recorded_by_staff_id;
    IF related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'staff tenant mismatch'; END IF;
  ELSIF TG_TABLE_NAME = 'assessment' AND NEW.created_by_staff_id IS NOT NULL THEN
    SELECT tenant_id INTO related_tenant FROM app.staff WHERE id = NEW.created_by_staff_id;
    IF related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'staff tenant mismatch'; END IF;
  END IF;
  IF TG_TABLE_NAME = 'teaching_assignment' OR TG_TABLE_NAME = 'schedule_slot' OR TG_TABLE_NAME = 'attendance_record' OR TG_TABLE_NAME = 'assessment' THEN
    SELECT tenant_id INTO related_tenant FROM app.class WHERE id = NEW.class_id; IF related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'class tenant mismatch'; END IF;
  END IF;
  IF TG_TABLE_NAME = 'teaching_assignment' OR TG_TABLE_NAME = 'schedule_slot' OR TG_TABLE_NAME = 'assessment' THEN
    SELECT tenant_id INTO related_tenant FROM app.subject WHERE id = NEW.subject_id; IF related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'subject tenant mismatch'; END IF;
  END IF;
  IF TG_TABLE_NAME = 'attendance_record' OR TG_TABLE_NAME = 'grade' THEN
    SELECT tenant_id INTO related_tenant FROM app.student WHERE id = NEW.student_id; IF related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'student tenant mismatch'; END IF;
  END IF;
  IF TG_TABLE_NAME = 'grade' THEN
    SELECT tenant_id INTO related_tenant FROM app.assessment WHERE id = NEW.assessment_id; IF related_tenant IS DISTINCT FROM NEW.tenant_id THEN RAISE EXCEPTION 'assessment tenant mismatch'; END IF;
  END IF;
  RETURN NEW;
END; $$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['teaching_assignment', 'schedule_slot', 'attendance_record', 'assessment', 'grade'] LOOP
    EXECUTE format('ALTER TABLE app.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('ALTER TABLE app.%I FORCE ROW LEVEL SECURITY', t);
    EXECUTE format('CREATE POLICY %I ON app.%I USING (tenant_id = app.current_tenant_id()) WITH CHECK (tenant_id = app.current_tenant_id())', t || '_tenant_isolation', t);
  END LOOP;
END; $$;

DROP TRIGGER IF EXISTS teaching_assignment_tenant_consistency ON app.teaching_assignment;
CREATE TRIGGER teaching_assignment_tenant_consistency BEFORE INSERT OR UPDATE ON app.teaching_assignment FOR EACH ROW EXECUTE FUNCTION app.enforce_pedagogy_tenant_consistency();
DROP TRIGGER IF EXISTS schedule_slot_tenant_consistency ON app.schedule_slot;
CREATE TRIGGER schedule_slot_tenant_consistency BEFORE INSERT OR UPDATE ON app.schedule_slot FOR EACH ROW EXECUTE FUNCTION app.enforce_pedagogy_tenant_consistency();
DROP TRIGGER IF EXISTS attendance_record_tenant_consistency ON app.attendance_record;
CREATE TRIGGER attendance_record_tenant_consistency BEFORE INSERT OR UPDATE ON app.attendance_record FOR EACH ROW EXECUTE FUNCTION app.enforce_pedagogy_tenant_consistency();
DROP TRIGGER IF EXISTS assessment_tenant_consistency ON app.assessment;
CREATE TRIGGER assessment_tenant_consistency BEFORE INSERT OR UPDATE ON app.assessment FOR EACH ROW EXECUTE FUNCTION app.enforce_pedagogy_tenant_consistency();
DROP TRIGGER IF EXISTS grade_tenant_consistency ON app.grade;
CREATE TRIGGER grade_tenant_consistency BEFORE INSERT OR UPDATE ON app.grade FOR EACH ROW EXECUTE FUNCTION app.enforce_pedagogy_tenant_consistency();
