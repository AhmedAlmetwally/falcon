[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 1
  ny = 1
  nz = 1
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 1
  zmin = 0
  zmax = 1
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  block = 0
  PorousFlowDictator = dictator
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'disp_x disp_y disp_z'
    number_fluid_phases = 1
    number_fluid_components = 1
  []
  [pc]
    type = PorousFlowCapillaryPressureVG
    m = 0.5
    alpha = 1
  []
[]


[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[BCs]
  [xmin]
    type = DirichletBC
    boundary = left
    variable = disp_x
    value = 0
  []
  [ymin]
    type = DirichletBC
    boundary = bottom
    variable = disp_y
    value = 0
  []
  [zmin]
    type = DirichletBC
    boundary = back
    variable = disp_z
    value = 0
  []
[]

[AuxVariables]
  [porepressure]
  []
[]


[Kernels]
  [TensorMechanics]
    displacements = 'disp_x disp_y disp_z'
  []
  [poro_x]
    type = PorousFlowEffectiveStressCoupling
    biot_coefficient = 0.3
    variable = disp_x
    component = 0
  []
  [poro_y]
    type = PorousFlowEffectiveStressCoupling
    biot_coefficient = 0.3
    variable = disp_y
    component = 1
  []
  [poro_z]
    type = PorousFlowEffectiveStressCoupling
    biot_coefficient = 0.3
    variable = disp_z
    component = 2
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
  []
  [elasticity_tensor]
    type = ComputeElasticityTensor
    # bulk modulus = 1, poisson ratio = 0.2
    C_ijkl = '0.5 0.75'
    fill_method = symmetric_isotropic
  []
  [strain]
    type = ComputeSmallStrain
    displacements = 'disp_x disp_y disp_z'
  []
  [stress]
    type = ComputeLinearElasticStress
  []
  [eff_fluid_pressure]
    type = PorousFlowEffectiveFluidPressure
  []
  [ppss]
    type = PorousFlow1PhaseP
    porepressure = porepressure
    capillary_pressure = pc
  []
[]

[Preconditioning]
  [andy]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -snes_atol -snes_rtol -snes_max_it -ksp_atol -ksp_rtol'
    petsc_options_value = 'gmres bjacobi 1E-10 1E-10 10 1E-15 1E-10'
  []
[]

[Executioner]
  type = Transient
  solve_type = Newton
  start_time = 0
  dt = 0.1
  end_time = 1

  accept_on_max_picard_iteration = true
  picard_max_its = 20
  picard_abs_tol = 1e-3

  relaxation_factor = 0.5
  relaxed_variables = 'disp_x disp_y disp_z'
[]

[Outputs]
  execute_on = 'timestep_end'
[]
