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
    porous_flow_vars = 'porepressure'
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
  [porepressure]
  []
[]

[AuxVariables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
  [porosity_Begin]
    order = CONSTANT
    family = MONOMIAL
  []
  [porosity_End]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [porosityBegin]
    type = PorousFlowPropertyAux
    variable = porosity_Begin
    property= porosity
    execute_on= TIMESTEP_BEGIN
  []
  [porosityEnd]
    type = PorousFlowPropertyAux
    variable = porosity_End
    property= porosity
    execute_on='INITIAL timestep_end'
  []
[]

[BCs]
  [p]
    type = FunctionDirichletBC
    boundary = 'bottom top'
    variable = porepressure
    function = t
  []
[]

[Kernels]
  [p_does_not_really_diffuse]
    type = Diffusion
    variable = porepressure
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
  []
  [ppss]
    type = PorousFlow1PhaseP
    porepressure = porepressure
    capillary_pressure = pc
  []
  [p_eff]
    type = PorousFlowEffectiveFluidPressure
  []
  [porosity]
    type = PorousFlowPorosity
    fluid = true
    mechanical = true
    ensure_positive = false
    porosity_zero = 0.1
    biot_coefficient = 0.6
    solid_bulk = 1
  []
  [vol_strain]
    type = PorousFlowVolumetricStrain
  []
[]

[MultiApps]
  [mechanics]
    type = TransientMultiApp
    input_files = vol_expansion_subM.i
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
[]

[Transfers]
  [porepressure]
    type = MultiAppMeshFunctionTransfer
    direction = to_multiapp
    multi_app = mechanics
    source_variable = porepressure
    execute_on= 'INITIAL TIMESTEP_BEGIN'
    variable = porepressure
  []
  [disp]
    type = MultiAppMeshFunctionTransfer
    direction = from_multiapp
    multi_app = mechanics
    source_variable = 'disp_x disp_y disp_z'
    variable = 'disp_x disp_y disp_z'
    execute_on=  'INITIAL TIMESTEP_BEGIN'
  []
[]

[Postprocessors]
  [corner_x]
    type = PointValue
    point = '1 1 1'
    variable = disp_x
  []
  [corner_y]
    type = PointValue
    point = '1 1 1'
    variable = disp_y
  []
  [corner_z]
    type = PointValue
    point = '1 1 1'
    variable = disp_z
  []
  [picard_its]
    type = NumPicardIterations
  [../]

  [./poronorm_Begin]
    type = ElementL2Norm
    variable = porosity_Begin
    execute_on = 'TIMESTEP_BEGIN'
    #outputs = none
  [../]
  [./poronorm_End]
    type = ElementL2Norm
    variable = porosity_End
    execute_on = 'INITIAL timestep_end'
  [../]
  [./poronorm_err]
    type = RelativeDifferencePostprocessor
    value1 = poronorm_Begin
    value2 = poronorm_End
    #outputs = none
  [../]
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
  custom_abs_tol = 1e-5

  disable_fixed_point_residual_norm_check = true
  disable_picard_residual_norm_check = true

  picard_custom_pp = poronorm_err

  relaxation_factor = 0.5
  relaxed_variables = 'porepressure'
[]

[Outputs]
  file_base = vol_expansion
  exodus = true
[]
