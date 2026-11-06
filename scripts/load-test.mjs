const url = process.env.LOAD_TEST_URL ?? "http://localhost:3001/api/health";
const concurrency = Number(process.env.LOAD_TEST_CONCURRENCY ?? 20);
const requests = Number(process.env.LOAD_TEST_REQUESTS ?? 100);
let next = 0;
let failures = 0;
async function worker() {
  while (true) {
    const index = next++;
    if (index >= requests) return;
    try {
      const response = await fetch(url);
      if (!response.ok) failures += 1;
    } catch {
      failures += 1;
    }
  }
}
await Promise.all(
  Array.from({ length: Math.min(concurrency, requests) }, worker),
);
console.log(JSON.stringify({ url, requests, concurrency, failures }));
if (failures) process.exitCode = 1;
