[Mesh]
  dim = 2
  file = square.e
#  init_unif_refine = 6
[]

[Variables]
  active = 'u v'

  [./u]
    order = FIRST
    family = LAGRANGE
  [../]

  [./v]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Preconditioning]
  active = 'PBP'

  [./PBP]
    solve_order = 'u v'
    preconditioner  = 'LU LU'
    off_diag_row    = 'v'
    off_diag_column = 'u'
  [../]
[]

[Kernels]
  active = 'diff_u conv_v diff_v'

  [./diff_u]
    type = Diffusion
    variable = u
  [../]

  [./conv_v]
    type = CoupledForce
    variable = v
    v = u
  [../]

  [./diff_v]
    type = Diffusion
    variable = v
  [../]
[]

[BCs]
  active = 'left_u right_u left_v'

  [./left_u]
    type = DirichletBC
    variable = u
    boundary = 1
    value = 0
  [../]

  [./right_u]
    type = DirichletBC
    variable = u
    boundary = 2
    value = 100
  [../]

  [./left_v]
    type = DirichletBC
    variable = v
    boundary = 1
    value = 0
  [../]

  [./right_v]
    type = DirichletBC
    variable = v
    boundary = 2
    value = 0
  [../]
[]

[Materials]
  active = constant

  [./constant]
    type = Constant
    block = 1
  [../]
[]

[Executioner]
  type = Steady

  l_max_its = 1
  nl_max_its = 1

  petsc_options = '-snes_mf'
[]

[Output]
  file_base = out
  output_initial = true
  interval = 1
  exodus = true
  perf_log = true
[]
   
    
