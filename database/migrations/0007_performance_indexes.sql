-- Supports tenant-scoped list pages, dashboards, and due-date processing.
CREATE INDEX IF NOT EXISTS student_tenant_name_idx ON app.student (tenant_id, last_name, first_name, id);
CREATE INDEX IF NOT EXISTS enrollment_tenant_year_status_idx ON app.enrollment (tenant_id, academic_year_id, status, student_id);
CREATE INDEX IF NOT EXISTS attendance_tenant_date_idx ON app.attendance_record (tenant_id, occurred_on DESC, class_id);
CREATE INDEX IF NOT EXISTS assessment_tenant_class_date_idx ON app.assessment (tenant_id, class_id, occurred_on DESC);
CREATE INDEX IF NOT EXISTS grade_tenant_assessment_idx ON app.grade (tenant_id, assessment_id, student_id);
CREATE INDEX IF NOT EXISTS invoice_tenant_status_due_idx ON app.invoice (tenant_id, status, due_at, issued_at DESC);
CREATE INDEX IF NOT EXISTS payment_tenant_paid_idx ON app.payment (tenant_id, paid_at DESC, id);
CREATE INDEX IF NOT EXISTS audit_event_tenant_occurred_idx ON app.audit_event (tenant_id, occurred_at DESC, id);
CREATE INDEX IF NOT EXISTS notification_tenant_status_scheduled_idx ON app.notification (tenant_id, status, scheduled_at);
CREATE INDEX IF NOT EXISTS report_export_tenant_status_idx ON app.report_export (tenant_id, status, created_at DESC);
