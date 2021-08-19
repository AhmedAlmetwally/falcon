[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 1
  ny = 1
  nz = 10
  xmin = -1
  xmax = 1
  ymin = -1
  ymax = 1
  zmin = 0
  zmax = 10
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
    type = MaterialRealAux
    variable = porosity_Begin
    property= PorousFlow_porosity_qp
    execute_on= TIMESTEP_BEGIN
  []
  [porosityEnd]
    type = MaterialRealAux
    variable = porosity_End
    property= PorousFlow_porosity_qp
    execute_on='INITIAL timestep_end'
  []
[]

[BCs]
  [topdrained]
    type = DirichletBC
    variable = porepressure
    value = 0
    boundary = front
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
  [flux]
    type = PorousFlowAdvectiveFlux
    variable = porepressure
    gravity = '0 0 0'
    fluid_component = 0
  []
[]

[Modules]
  [FluidProperties]
    [simple_fluid]
      type = SimpleFluidProperties
      bulk_modulus = 8
      density0 = 1
      thermal_expansion = 0
      viscosity = 1
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
    solid_bulk = 4
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1.5 0 0   0 1.5 0   0 0 1.5'
  []
  [relperm]
    type = PorousFlowRelativePermeabilityCorey
    n = 0 # unimportant in this fully-saturated situation
    phase = 0
  []
[]

[MultiApps]
  [mechanics]
    type = TransientMultiApp
    input_files = terzaghi_subM.i
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
  [p0]
    type = PointValue
    outputs = csv
    point = '0 0 0'
    variable = porepressure
    use_displaced_mesh = false
  []
  [p1]
    type = PointValue
    outputs = csv
    point = '0 0 1'
    variable = porepressure
    use_displaced_mesh = false
  []
  [p2]
    type = PointValue
    outputs = csv
    point = '0 0 2'
    variable = porepressure
    use_displaced_mesh = false
  []
  [p3]
    type = PointValue
    outputs = csv
    point = '0 0 3'
    variable = porepressure
    use_displaced_mesh = false
  []
  [p4]
    type = PointValue
    outputs = csv
    point = '0 0 4'
    variable = porepressure
    use_displaced_mesh = false
  []
  [p5]
    type = PointValue
    outputs = csv
    point = '0 0 5'
    variable = porepressure
    use_displaced_mesh = false
  []
  [p6]
    type = PointValue
    outputs = csv
    point = '0 0 6'
    variable = porepressure
    use_displaced_mesh = false
  []
  [p7]
    type = PointValue
    outputs = csv
    point = '0 0 7'
    variable = porepressure
    use_displaced_mesh = false
  []
  [p8]
    type = PointValue
    outputs = csv
    point = '0 0 8'
    variable = porepressure
    use_displaced_mesh = false
  []
  [p9]
    type = PointValue
    outputs = csv
    point = '0 0 9'
    variable = porepressure
    use_displaced_mesh = false
  []
  [p99]
    type = PointValue
    outputs = csv
    point = '0 0 10'
    variable = porepressure
    use_displaced_mesh = false
  []
  [zdisp]
    type = PointValue
    outputs = csv
    point = '0 0 10'
    variable = disp_z
    use_displaced_mesh = false
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

  [./num_dofs_nl]
    type = NumDOFs
    system = NL
  [../]
  [./num_dofs_AUX]
    type = NumDOFs
    system = AUX
  [../]
  [./num_dofs_ALL]
    type = NumDOFs
    system = ALL
  [../]
  [./num_elems_total]
    type = NumElems
    elem_filter = 'TOTAL'
    execute_on = 'initial timestep_end'
  [../]
  [./num_nonlinear_iterations]
    type = NumNonlinearIterations
  [../]
  [./num_linear_iterations]
    type = NumLinearIterations
  [../]
  [./num_nodes]
    type = NumNodes
    execute_on = TIMESTEP_END
  [../]
  [./num_vars]
    type = NumVars
    system = 'ALL'
  [../]
  [./num_aux]
    type = NumVars
    system = 'AUX'
  [../]
  [./num_NL_vars]
    type = NumVars
    system = 'NL'
  [../]
  [dt1]
    type = TimestepSize
    execute_on = 'timestep_end'
  []
  [memory]
    type = MemoryUsage
    mem_units=megabytes
  []
  [./runtime]
    type = PerfGraphData
    data_type = TOTAL
    section_name = 'Root'
  [../]

  #[./final_residual]
  #  type = Residual
  #  residual_type = final
  #[../]

  #[./porepressure_res_l2]
  #  type = VariableResidual
  #  variable = porepressure
  #[../]

  [dt]
    type = FunctionValuePostprocessor
    outputs = console
    function = if(0.5*t<0.1,0.5*t,0.1)
  []
[]


[Preconditioning]
  [andy]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -snes_atol -snes_rtol -snes_max_it'
    petsc_options_value = 'gmres asm lu 1E-14 1E-10 10000'
  []
[]

[Executioner]
  type = Transient
  solve_type = Newton
  start_time = 0
  end_time = 10
  accept_on_max_picard_iteration = true
  picard_max_its = 20
  custom_abs_tol = 1e-3

  disable_fixed_point_residual_norm_check = true
  disable_picard_residual_norm_check = true

  picard_custom_pp = poronorm_err

  relaxation_factor = 0.5
  relaxed_variables = 'porepressure'

#  [./Adaptivity]
#    refine_fraction = .02
#    coarsen_fraction = .3
#    initial_adaptivity = 3
#    max_h_level = 2
#    error_estimator = KellyErrorEstimator
#    weight_names='porepressure'
#    weight_values= '0.5'
#  [../]


  [TimeStepper]
    type = PostprocessorDT
    postprocessor = dt
    dt = 0.0001
  []
[]

[Outputs]
  execute_on = 'timestep_end'
  file_base = terzaghi_masterF
  perf_graph = true
  exodus = true
  [csv]
    type = CSV
  []
[]
