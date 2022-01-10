.global poly


poly:
  movi d0, #0x1
  movi d1, #0x2

  pmul q3, q0, q1

  mov w0, #42

  ret
