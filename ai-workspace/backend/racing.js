export function raceAdvice(state = {}) {
  const speed = Number(state.speed || 0);
  const nitro = Number(state.nitro ?? 0);
  const position = Number(state.position || 1);
  if (nitro > 65 && speed > 100) return { action: 'SAVE', reason: 'Keep nitro for an overtake or final straight.' };
  if (position > 1 && nitro > 25) return { action: 'NITRO', reason: 'Use nitro for a controlled overtake.' };
  if (speed < 70) return { action: 'ACCELERATE', reason: 'Build speed before the next section.' };
  return { action: 'STEADY', reason: 'Maintain speed and avoid unnecessary collisions.' };
}
