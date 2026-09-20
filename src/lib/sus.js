export function calculateSUS(values) {
  return values.reduce((total, value, index) => total + (index % 2 === 0 ? value - 1 : 5 - value), 0) * 2.5
}
