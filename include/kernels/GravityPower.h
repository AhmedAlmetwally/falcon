#ifndef GRAVITYPOWER_H
#define GRAVITYPOWER_H

#include "Kernel.h"
#include "Material.h"


//ForwardDeclarations
class GravityPower;

template<>
InputParameters validParams<GravityPower>();

class GravityPower : public Kernel
{
public:

  GravityPower(std::string name, MooseSystem & moose_system, InputParameters parameters);
  
protected:
  virtual Real computeQpResidual();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  unsigned int _pv_var;
  std::vector<Real> & _pv;

  Real _acceleration;
};
 
#endif
