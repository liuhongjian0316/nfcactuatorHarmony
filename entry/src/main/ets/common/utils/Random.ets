export function getRandomColor(): string {
  return `#${Math.random().toString(16).substring(2, 8).padEnd(6, '0')}`;
}