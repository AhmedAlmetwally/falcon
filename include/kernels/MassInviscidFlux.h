#ifndef MASSINVISCIDFLUX_H
#define MASSINVISCIDFLUX_H

#include "Kernel.h"

//ForwardDeclarations
class MassInviscidFlux;

template<>
InputParameters validParams<MassInviscidFlux>();

class MassInviscidFlux : public Kernel
{
public:

  MassInviscidFlux(std::string name, MooseSystem & moose_system, InputParameters parameters);
  
protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  unsigned int _pu_var;
  MooseArray<Real> & _pu;

  unsigned int _pv_var;
  MooseArray<Real> & _pv;

  unsigned int _pw_var;
  MooseArray<Real> & _pw;
};
 
#endif
