// Active only in January (0) and December (11)
export default function isRewindActive() {
  const currentMonth = new Date().getMonth();
  return currentMonth === 0 || currentMonth === 11;
}
