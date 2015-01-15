#ifndef ENERGYVISCOUSFLUX_H
#define ENERGYVISCOUSFLUX_H

#include "Kernel.h"
#include "Material.h"


//ForwardDeclarations
class EnergyViscousFlux;

template<>
InputParameters valid_params<EnergyViscousFlux>();

class EnergyViscousFlux : public Kernel
{
public:

  EnergyViscousFlux(std::string name,
                  InputParameters parameters,
                  std::string var_name,
                  std::vector<std::string> coupled_to=std::vector<std::string>(0),
                    std::vector<std::string> coupled_as=std::vector<std::string>(0));

  virtual void subdomainSetup();

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  unsigned int _u_vel_var;
  std::vector<Real> & _u_vel;

  unsigned int _v_vel_var;
  std::vector<Real> & _v_vel;

  unsigned int _w_vel_var;
  std::vector<Real> & _w_vel;

  unsigned int _temp_var;
  std::vector<RealGradient> & _grad_temp;

  std::vector<RealTensorValue> * _viscous_stress_tensor;
  std::vector<Real> * _thermal_conductivity;
};
 
#endif
