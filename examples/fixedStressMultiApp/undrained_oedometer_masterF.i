[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 1
  ny = 1
  nz = 1
  xmin = -0.5
  xmax = 0.5
  ymin = -0.5
  ymax = 0.5
  zmin = -0.5
  zmax = 0.5
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  PorousFlowDictator = dictator
  block = 0
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
    m = 0.8
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


[Kernels]
  [poro_vol_exp]
    type = PorousFlowMassVolumetricExpansion
    variable = porepressure
    fluid_component = 0
  []
  [mass0]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = porepressure
  []
[]

[Modules]
  [FluidProperties]
    [simple_fluid]
      type = SimpleFluidProperties
      bulk_modulus = 8
      density0 = 1
      thermal_expansion = 0
    []
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
  []
  [eff_fluid_pressure]
    type = PorousFlowEffectiveFluidPressure
  []
  [vol_strain]
    type = PorousFlowVolumetricStrain
  []
  [ppss]
    type = PorousFlow1PhaseP
    porepressure = porepressure
    capillary_pressure = pc
  []
  [massfrac]
    type = PorousFlowMassFraction
  []
  [simple_fluid]
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid
    phase = 0
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
[]

[MultiApps]
  [mechanics]
    type = TransientMultiApp
    input_files = undrained_oedometer_subM.i
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
  [stress_xx]
    type = MultiAppPostprocessorTransfer
    multi_app = mechanics
    direction = from_multiapp
    reduction_type = average
    from_postprocessor = 'stress_xx'
    to_postprocessor = 'stress_xx'
    #execute_on= 'INITIAL TIMESTEP_END'
  []
  [stress_yy]
    type = MultiAppPostprocessorTransfer
    multi_app = mechanics
    direction = from_multiapp
    reduction_type = average
    from_postprocessor = 'stress_yy'
    to_postprocessor = 'stress_yy'
    #execute_on= 'INITIAL TIMESTEP_END'
  []
  [stress_zz]
    type = MultiAppPostprocessorTransfer
    multi_app = mechanics
    direction = from_multiapp
    reduction_type = average
    from_postprocessor = 'stress_zz'
    to_postprocessor = 'stress_zz'
    #execute_on= 'INITIAL TIMESTEP_END'
  []


[]

[Postprocessors]
  [stress_xx]
     type = Receiver
     outputs = csv
  []
  [stress_yy]
     type = Receiver
     outputs = csv
  []
  [stress_zz]
     type = Receiver
     outputs = csv
  []
  [fluid_mass]
    type = PorousFlowFluidMass
    fluid_component = 0
    execute_on = 'initial timestep_end'
    use_displaced_mesh = true
  []
  [p0]
    type = PointValue
    outputs = csv
    point = '0 0 0'
    variable = porepressure
  []
  [zdisp]
    type = PointValue
    outputs = csv
    point = '0 0 0.5'
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
    petsc_options_iname = '-ksp_type -pc_type -snes_atol -snes_rtol -snes_max_it'
    petsc_options_value = 'bcgs bjacobi 1E-14 1E-8 10000'
  []
[]

[Executioner]
  type = Transient
  solve_type = Newton
  start_time = 0
  end_time = 10
  dt = 1
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
  execute_on = 'timestep_end'
  file_base = undrained_oedometer
  [csv]
    type = CSV
  []
[]
