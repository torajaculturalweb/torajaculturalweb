import { describe, expect, it } from 'vitest'
import { calculateSUS } from './lib/sus.js'
describe('SUS scoring',()=>{
  it('menghasilkan 100 untuk jawaban terbaik',()=>expect(calculateSUS([5,1,5,1,5,1,5,1,5,1])).toBe(100))
  it('menghasilkan 0 untuk jawaban terburuk',()=>expect(calculateSUS([1,5,1,5,1,5,1,5,1,5])).toBe(0))
})
