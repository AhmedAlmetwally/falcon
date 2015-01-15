#ifndef ENTHALPYCONVECTIONSTEAM
#define ENTHALPYCONVECTIONSTEAM

#include "Kernel.h"
#include "Material.h"

//Forward Declarations
class EnthalpyConvectionSteam;

template<>
InputParameters validParams<EnthalpyConvectionSteam>();

class EnthalpyConvectionSteam : public Kernel
{
public:

  EnthalpyConvectionSteam(const std::string & name, InputParameters parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);
  
    MaterialProperty<Real> & _Dtau_steamDH;
    MaterialProperty<Real> & _Dtau_steamDP;
    MaterialProperty<RealGradient> & _darcy_mass_flux_steam;
    MaterialProperty<Real> & _tau_steam;
  
    //VariableGradient & _grad_enthalpy_steam;
    VariableValue & _enthalpy_steam;
    VariableValue & _denthalpy_steamdH_P;
    VariableValue & _denthalpy_steamdP_H;
    unsigned int  _p_var;
    VariableGradient & _grad_p;
  
};
#endif //ENTHALPYCONVECTIONSTEAM
