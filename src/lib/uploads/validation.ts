const maxUploadBytes = 10 * 1024 * 1024;
const allowedMimeTypes = new Set([
  "application/pdf",
  "image/jpeg",
  "image/png",
  "image/webp",
  "text/csv",
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
]);

export function validateUpload(file: Pick<File, "size" | "type" | "name">) {
  if (file.size <= 0 || file.size > maxUploadBytes)
    throw new Error("Le fichier doit peser au maximum 10 Mo.");
  if (!allowedMimeTypes.has(file.type))
    throw new Error("Ce type de fichier n’est pas autorisé.");
  if (file.name.length > 180)
    throw new Error("Le nom du fichier est trop long.");
}

export { maxUploadBytes };
