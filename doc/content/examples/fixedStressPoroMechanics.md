# FixedStressPoroMechanics--Under Development

The following examples show the decoupled fixed-stress approach to simulate the single-phase *poro-elastic* or *thermo-poro-elastic* problems. The porous fluid-flow physics is coupled to mechanics and/or heat flow using the [TransientMultiApp](/multiapps/TransientMultiApp.md) system in MOOSE. These examples are compared with the fully-coupled test cases [poro_elasticity_tests](poro_elasticity_tests.md) problems. The `TransientMultiApp` is used to to link the decoupled physics and perform simulations with sub-applications that progress in time with the main application. The transfer system  ([MultiAppMeshFunctionTransfer](/transfers/MultiAppMeshFunctionTransfer.md) or [MultiAppCopyTransfer](/transfers/MultiAppCopyTransfer.md)) performs a transfer of the coupled variables from and to the sub-application. The transfer utilizes the finite element function of the master application to perform the transfer. Figure one shows the fixed stress approach used for solving the poromechanics problems.

!media ~/projects/falcon/doc/content/examples/fixedStressMedia/fixedStressFlowchart.png
      id=fig:fixedStressFlowchart
      style=width:80%;margin-left:10px;
      caption=Fixed stress decoupling algorithm flowchart

## MasterApp Physics: Fluid Flow

The fluid flow equation in a fully-coupled setting is described in [PorousFlow fluid equation](/porous_flow/governing_equations.md) along with its [nomenclature](/porous_flow/nomenclature.md). The continuity equation is used to describe the mass conservation for fluid species in porous media where the species are parameterised by $\kappa = 1,2,3,\ldots$.:

\begin{equation}
\label{eq:mass_cons_sp}
0 = \frac{\partial M^{\kappa}}{\partial t} + M^{\kappa}\nabla\cdot{\mathbf
  v}_{s} + \nabla\cdot \mathbf{F}^{\kappa} + \Lambda M^{\kappa} - \phi I_{\mathrm{chem}} - q^{\kappa} \ .
\end{equation}

Where:
$M$ is the mass of fluid per bulk volume (measured in kg.m$^{-3}$),

$\mathbf{v}_{s}$ is the velocity of the porous solid skeleton (measured in m.s$^{-1}$),

$\mathbf{F}$ is the flux (a vector, measured kg.s$^{-1}$.m$^{-2}$),

$\Lambda$ is a radioactive decay rate,

$\phi I_{\mathrm{chem}}$ represents chemical precipitation or dissolution and $q$ is a source (measured in kg.m$^{-3}$.s$^{-1}$).

The coupled term to the solid mechanics, in [eq:mass_cons_sp], is the $M\nabla\cdot \mathbf{v}_{s}$ term, as well as via changes in porevolume (porosity) and permeability. Heat flow and chemical reactions affect the fluid flow in the terms require equations of state in [eq:mass_cons_sp], as well as the source term $q^{\kappa}$. The next step of that work will to show three field coupling (flow, mechanics, and thermal).

Here, we will focus only on the ability to couple fluid flow to solid mechanics, and thus includes poroelasticity, which is the theory of a fully-saturated single-phase fluid with constant bulk density and constant viscosity coupled to small-strain isotropic elasticity. In poromechanics problems, porosity should evolve with time as fluid porepressure and volumetric strain changes. The PorousFlow module allows as discussed further [here](PorousFlowFullySaturatedMassTimeDerivative.md).

Moose is structured to represent each part of the governing equation above ([eq:mass_cons_sp]) in separate
`Kernels`. Table 1 summarizes those kernels included in the PorousFlow module to simulate the fluid flow physics[*](/porous_flow/governing_equations.md).

!table id=kernels caption=Available `Kernels`
| Equation | Kernel |
| --- | --- |
| $\frac{\partial}{\partial t}\left(\phi\sum_{\beta}S_{\beta}\rho_{\beta}\chi_{\beta}^{\kappa}\right)$ | [`PorousFlowMassTimeDerivative`](PorousFlowMassTimeDerivative.md) |
| $-\nabla\cdot \sum_{\beta}\chi_{\beta}^{\kappa} \rho_{\beta}\frac{k\,k_{\mathrm{r,}\beta}}{\mu_{\beta}}(\nabla P_{\beta} - \rho_{\beta} \mathbf{g})$ | [`PorousFlowAdvectiveFlux`](PorousFlowAdvectiveFlux.md) |
| $\phi\sum_{\beta}S_{\beta}\rho_{\beta}\chi_{\beta}^{\kappa}\nabla\cdot\mathbf{v}_{s}$ | [`PorousFlowMassVolumetricExpansion`](PorousFlowMassVolumetricExpansion.md) |


### Required Materials

Considering the nature of the problem as a porous media problem, the basic materials to describe the porous media for the fluid flow masterApp are:

- Porosity, eg, [PorousFlowPorosity](/PorousFlowPorosity.md)
- Permeability, eg, [PorousFlowPermeabilityConst](PorousFlowPermeabilityConst.md)
- Biot Modulus, eg, [PorousFlowConstantBiotModulus](/PorousFlowConstantBiotModulus.md)
- Thermal Expansion Coefficient, eg, [PorousFlowConstantThermalExpansionCoefficient](/PorousFlowConstantThermalExpansionCoefficient.md), if coupling with the termal field will be considered

** fix me strain calculator might be needed for porosity!

Other materials are needed to describe the fluid itself and PorousFlow adds many them automatically as in [PorousFlowSingleComponentFluid](/PorousFlowSingleComponentFluid.md).

### Porosity update from mechanics subApp transfer: PorousFlowPorosity

Updating the porosity is a major aspect of poromechanics. The [PorousFlowPorosity](/PorousFlowPorosity.md) computes porosity (at the nodes or quadpoints, depending on the `at_nodes` flag). The transfered strain and the new displacements from the mechanics subApp will be used to update the porosity:
\begin{equation}
\label{eq:poro_evolve}
\phi + M = \alpha_{B} + (\phi_{0} + M_{\mathrm{ref}} - \alpha_{B})\times \exp \left( \frac{\alpha_{B}
  - 1}{K}(P_{f} - P_{f}^{\mathrm{ref}}) - \epsilon^{\mathrm{total}}_{ii} + \alpha_{T}(T - T^{\mathrm{ref}}) \right) \ ,
\end{equation}
A full description is provided in the [porosity documentation](/porous_flow/porosity.md)

Flags provided to `PorousFlowPorosity` control its evolution.

- If `mechanical = true` then the porosity will depend on $\epsilon^{\mathrm{total}}_{ii}$.
  Otherwise that term in [eq:poro_evolve] is ignored.

- If `fluid = true` then the porosity will depend on $(P_{f} - P_{f}^{\mathrm{ref}})$.  Otherwise
  that term in [eq:poro_evolve] is ignored.

- If `thermal = true` then the porosity will depend on $(T - T^{\mathrm{ref}})$.  Otherwise that term
  in [eq:poro_evolve] is ignored.

- If `chemical = true` then porosity will depend on $M$.  Otherwise that term in
  [eq:poro_evolve] is ignored.

## SubApp Physics: Solid Mechanics

The solid mechanics is handled by the [Tensor Mechanics](/tensor_mechanics/index.md) module. For poromechanics problems, the total stress tensor is denoted by $\sigma^{\mathrm{tot}}$.  The pore pressure is handled as an externally applied mechanical force along with external boundary forces that will create a nonzero $\sigma^{\mathrm{tot}}$, and conversely, resolving $\sigma^{\mathrm{tot}}$ into forces yields the forces on nodes in the finite-element mesh. The effective stress tensor by $\sigma^{\mathrm{eff}}$ is defined by
\begin{equation}
\label{eq:eff_stress}
\sigma^{\mathrm{eff}}_{ij} = \sigma^{\mathrm{tot}}_{ij} +
\alpha_{B}\delta_{ij}P_{f} \ .
\end{equation}
The notation is as follows.

- $P_{f}$ is the porepressure.
- $\alpha_{B}$ is the *Biot coefficient*.  

It is assumed that the elastic constitutive law reads
\begin{equation}
\label{eq:elasticity}
\sigma_{ij}^{\mathrm{eff}} = E_{ijkl}(\epsilon^{\mathrm{elastic}}_{kl} -
\delta_{kl}\alpha_{T}T)\ ,
\end{equation}
with $\alpha_{T}$ being the thermal expansion coefficient of the drained porous skeleton, and $\epsilon_{kl} = (\nabla_{k}u_{l} +
\nabla_{l}u_{k})/2$ being the usual total strain tensor ($u$ is the deformation of the porous solid), which can be split into the elastic
and plastic parts, $\epsilon = \epsilon^{\mathrm{elastic}} + \epsilon^{\mathrm{plastic}}$, and $E_{ijkl}$ being the elasticity
tensor (the so-called *drained* version).

For simulations that couple fluid flow to mechanics,  the following kernels are implemented in the mechanics subApp:

- [StressDivergenceTensors](/StressDivergenceTensors.md)
- [Gravity](/Gravity.md)
- [PorousFlowEffectiveStressCoupling](/PorousFlowEffectiveStressCoupling.md)

### Required Materials

The basic materials to run the mechanics subApp for a poromechanics simulation are:

- An elasticity tensor, eg, [ComputeIsotropicElasticityTensor](/ComputeIsotropicElasticityTensor.md)
- A strain calculator, eg, [ComputeSmallStrain](/ComputeSmallStrain.md)
- A stress calculator, eg [ComputeLinearElasticStress](/ComputeLinearElasticStress.md)


## Convergence criteria -- Under Development

It is important to set the global convergence criterion appropriately as the `-nl_abs_tol`, or equivalently, PETSc's `-snes_atol`, also a relative tolerance
`nl_rel_tol` (or PETSc's `-snes_rtol`). The acceptable error in strains or displacements (SubApp) and mass (MasterApp) would be beneficial to control the solution with a relative convergence on porosity as in figure (1).

## Verification Cases -- Under Development
These examples are compared with the fully-coupled test cases [poro_elasticity_tests](poro_elasticity_tests.md) problems.

## 1. Volumetric expansion due to increasing porepressure

The porepressure within a fully-saturated sample is increased:
\begin{equation}
P_{\mathrm{f}} = t \ .
\end{equation}
Zero mechanical pressure is applied to the sample's exterior, so that
no Neumann BCs are needed on the sample.  No fluid flow occurs since
the porepressure is increased uniformly throughout the sample.

The fluid flow masterApp input file:

!listing /projects/falcon/examples/fixedStressMultiApp/vol_expansion_masterF.i

The mechanics supApp input file:

!listing /projects/falcon/examples/fixedStressMultiApp/vol_expansion_subM.i

The effective stresses should then evolve as
$\sigma_{ij}^{\mathrm{eff}} = \alpha t \delta_{ij}$, and the
volumetric strain $\epsilon_{00}+\epsilon_{11}+\epsilon_{22} = \alpha
t/K$. The decoupled version produces this result correctly.

## 2. Undrained oedometer test

A cubic single-element fully-saturated sample has roller BCs applied
to its sides and bottom.  All the sample's boundaries are impermeable.
A downwards (normal) displacement, $u_{z}$, is applied to its
top, and the rise in porepressure and effective stress is observed.
(Here $z$ denotes the direction normal to the top face.)  There is
no fluid flow in the single element.


The fluid flow masterApp input file:

!listing /projects/falcon/examples/fixedStressMultiApp/undrained_oedometer_masterF.i

The mechanics supApp input file:

!listing /projects/falcon/examples/fixedStressMultiApp/undrained_oedometer_subM.i


Under these conditions, assuming constant porosity, and denoting the
height ($z$ length) of the sample by $L$:
\begin{equation}
\begin{array}{rcl}
P_{\mathrm{f}} & = & -K_{f}\log(1 - u_{z}) \ , \\
\sigma_{xx}^{\mathrm{eff}} & = & \left(K - \frac{2}{3}G\right)u_{z}/L \ ,  \\
\sigma_{zz}^{\mathrm{eff}} & = & \left(K + \frac{4}{3}G\right)u_{z}/L \ .
\end{array}
\end{equation}
The decoupled version produces this result correctly.

## 3. Terzaghi consolidation of a drained medium

A saturated sample sits in a bath of water.  It is constrained on its sides and bottom.  Its sides and bottom are also impermeable.  Initially it is unstressed ($\sigma_{ij} = 0 = P_{\mathrm{f}}$, at $t=0$).  A normal stress, $q$, is applied to the sample's top.  The sample compresses instantaneously due to the instantaneous application of $q$, and then slowly compresses further as water is squeezed out from the sample's top surface. Denote the sample's height ($z$-length) by $h$.  Define
\begin{equation}
p_{0} = \frac{\alpha q M}{S(K + 4G/3) + \alpha^{2}M} \ .
\end{equation}
This is the porepressure that results from the instantaneous application of $q$: MOOSE calculates this correctly.  The solution for porepressure is
\begin{equation}
P_{\mathrm{f}} = \frac{4p_{0}}{\pi}\sum_{n=1}^{\infty} \frac{(-1)^{n-1}}{2n-1} \cos \left( \frac{(2n-1)\pi z}{2h} \right) \exp \left( -(2n-1)^{2} \pi^{2} \frac{ct}{4h^{2}} \right) \ .
\end{equation}
In this equation, $c$ is the "consolidation coefficient": $c = k (K + 4G/3) M/(K + 4G/3 + \alpha^{2} M)$, where the permeability tensor is $k_{ij} = \mathrm{diag}(k, k, k)$.  The so-called degree-of-consolidation is defined by
\begin{equation}
U = \frac{u_{z} - u_{z}^{0}}{u_{z}^{\infty} - u_{z}^{0}} \ ,
\end{equation}
where $u_{z}$ is the vertical displacement of the top surface (downwards is positive), and $u_{z}^{0}$ is the instantaneous displacement due to the instantaneous application of $q$, and $u_{z}^{\infty}$ is the final displacement.  This has solution
\begin{equation}
U = 1 - \frac{8}{\pi^{2}}\sum_{n=1}^{\infty} \frac{1}{(2n-1)^{2}} \exp \left(-(2n-1)^{2}\pi^{2}\frac{ct}{4h^{2}} \right) \ .
\end{equation}

The input file for that matches the theoretical setup exactly is:

The fluid flow masterApp input file:

!listing /projects/falcon/examples/fixedStressMultiApp/terzaghi_masterF.i

The mechanics supApp input file:

!listing /projects/falcon/examples/fixedStressMultiApp/terzaghi_subM.i


The decoupled fixed stress version produces the expected results correctly, as may be seen from [terzaghi_u] and [terzaghi_p].

!media /falcon/doc/content/examples/fixedStressMedia/terzaghi1.png style=width:50%;margin-left:10px caption=Degree of consolidation in the Terzaghi experiment.  id=terzaghi_u

!media /falcon/doc/content/examples/fixedStressMedia/terzaghi2.png  style=width:50%;margin-left:10px caption=Porepressure at various times in the Terzaghi experiment.  id=terzaghi_p

## 4. Mandel's consolidation of a drained medium

A sample's dimensions are $-a \leq x \leq a$ and $-b \leq y \leq b$, and it is in plane strain (no $z$ displacement).  It is squashed with
constant normal force by impermeable, frictionless plattens on its top and bottom surfaces (at $y = \pm b$).  Fluid is allowed to leak out
from its sides (at $x = \pm a$), but all other surfaces are impermeable.  This is called Mandel's problem.

The solution for porepressure and displacements is given in [!citet](doi:10.1002/nag.1610120508).  The solution involves
rather lengthy infinite series.

As is common in the literature, this is simulated by considering the quarter-sample, $0\leq x \leq a$ and $0\leq y\leq b$, with
impermeable, roller BCs at $x=0$ and $y=0$ and $y=b$.  Porepressure is fixed at zero on $x=a$.  Porepressure and displacement are initialised
to zero.  Then the top ($y=b$) is moved downwards with prescribed velocity, so that the total force that is induced by this downwards
velocity is fixed.  The velocity is worked out by solving Mandel's problem analytically, and the total force is monitored in the
simulation to check that it indeed remains constant.

The simulations use 10 elements in the $x$ direction and 1 in the $y$ direction.

The fluid flow masterApp input file:

!listing /projects/falcon/examples/fixedStressMultiApp/mandel_masterF.i

The mechanics supApp input file:

!listing /projects/falcon/examples/fixedStressMultiApp/mandel_subM.i



The figures below present the results.

!media /falcon/doc/content/examples/fixedStressMedia/mandel1.png style=width:50%;margin-left:10px caption=Mandel's problem: Porepressure at points in the sample.  id=terzaghi_u

!media /falcon/doc/content/examples/fixedStressMedia/mandel2.png  style=width:50%;margin-left:10px caption=Mandel's problem: total downwards force.  id=terzaghi_p

!media /falcon/doc/content/examples/fixedStressMedia/mandel3HeavilyMeshed.png style=width:50%;margin-left:10px caption=performance enhancement using fixed stress approach for heavily meshed Mandel problem over the fully coupled version.  id=mandel3HeavilyMeshed


## Heavy models

## 1. Heterogeneous models

Realistic models of porous media often feature spatially-varying material properties, especially
porosity and permeability. Heterogeneity can simply be read from an external data file. In
this example, we consider the 2D model of permeability heterogeneity presented as Case 1 of the tenth
[SPE comparative problem](https://www.spe.org/web/csp/datasets/set01.htm).

The permeability data for this model is read from an ASCII file containing coordinates and permeability
values (in millidarcys):

!listing modules/porous_flow/examples/reservoir_model/spe10_case1.data

A [PiecewiseMultilinear](PiecewiseMultilinear.md) function is used to interpolate the permeability to the
mesh.

!listing modules/porous_flow/examples/reservoir_model/regular_grid.i block=Functions

Constant Monomial AuxVariables are used to store the permeability read from the data file:

!listing modules/porous_flow/examples/reservoir_model/regular_grid.i block=AuxVariables

A [FunctionAux](FunctionAux.md) AuxKernel is used to populate the AuxVariables.

In this example, the permeability in the data file is in millidarcys. As PorousFlow expects permeability
in SI units of m$^2$, we multiply each permeability value by $9.869233 \times 10^{-16}$ and save these
values in a new AuxVariable:

!listing modules/porous_flow/examples/reservoir_model/regular_grid.i block=AuxKernels

As this interpolation and multiplication is only required at the beginning of the simulation, we set
the `execute_on` parameter to `initial` only.

Finally, the heterogeneous permeability (in m$^2$) can be used in the calculation using a [PorousFlowPermeabilityConstFromVar](PorousFlowPermeabilityConstFromVar.md) material.

!listing modules/porous_flow/examples/reservoir_model/regular_grid.i block=Materials/permeability

The above steps create the following heterogeneous model that can then be used in a simulation:

!media media/porous_flow/spe10_case1.png
       id=fig:regular_grid
       style=width:80%;margin-left:10px;
       caption=Heterogeneous permeability for SPE comparative problem case 1

Although this example is for a two-dimensional mesh, the procedure for producing a three-dimensional
mesh is identical.

## 2. Reservoir models

Often geological models are created using a modelling package to create realistic interpretations
of the geology. In this case, some pre-processing of the geological model is often required before
it can be used in PorousFlow. The following example shows how to use an Exodus mesh created from a reservoir model in a PorousFlow
simulation. For this example, we use publicly available data from the [SAIGUP](https://www.nr.no/saigup)
project to construct the heterogeneous reservoir model shown in [fig:field_model].

!media media/porous_flow/saigup.png
      id=fig:field_model
      style=width:80%;margin-left:10px;
      caption=Heterogeneous permeability for SAIGUP model

The heterogeneous porosity and permeability can then be read from the grid and used in the
calculations using the following steps:

First, the mesh (containing the heterogeneous reservoir properties) is read into PorousFlow:

!listing modules/porous_flow/examples/reservoir_model/field_model.i block=Mesh

Constant monomial AuxVariables are then created. As the reservoir model again contains permeability
in millidarcys, additional AuxVariables are also declared to hold the permeability in SI units (m$^2$).

The values of the AuxVariables for porosity and the components of permeability in millidarcys are set
using the `initial_from_file_var` parameter. These AuxVariables are not modified throughout the simulation,
so represent the initial heterogeneity of the model.

!listing modules/porous_flow/examples/reservoir_model/field_model.i block=AuxVariables

Like the previous example, the permeability can be converted to SI units using a [ParsedAux](ParsedAux.md)
AuxKernel for each component.

!listing modules/porous_flow/examples/reservoir_model/field_model.i block=AuxKernels

The heterogeneous porosity and permeabilities can then be used in the calculations:

!listing modules/porous_flow/examples/reservoir_model/field_model.i block=Materials/porosity

!listing modules/porous_flow/examples/reservoir_model/field_model.i block=Materials/permeability

Using this process, complex geological models with heterogeneous reservoir properties can be used in
PorousFlow.

!bibtex bibliography
