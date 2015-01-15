[Mesh]
  dim = 2
  file = steady_out.e
[]

[Variables]
  active = 'u'

  [./u]
    order = FIRST
    family = LAGRANGE
    initial_from_file_var = u
    initial_from_file_timestep = 2
  [../]
[]

[Kernels]
  active = 'bodyforce ie'

  [./bodyforce]
    type = BodyForce
    variable = u
    value = 10.0
  [../]

  [./ie]
    type = ImplicitEuler
    variable = u
  [../]
[]

[BCs]
  active = 'left right'

  [./left]
    type = DirichletBC
    variable = u
    boundary = 1
    value = 0
  [../]

  [./right]
    type = DirichletBC
    variable = u
    boundary = 2
    value = 1
  [../]
[]

[Materials]
  active = constant

  [./constant]
    type = Constant
    block = 1
  [../]
[]

[Execution]
  type = Transient
  perf_log = true
  petsc_options = '-snes_mf_operator'

  [./Transient]
    start_time = 0.0
    num_steps = 10
    dt = .1
  [../]  
[]

[Output]
  file_base = out
  output_initial = true
  interval = 1
  exodus = true
[]
   
    
