#ifndef COUPLEDAUX_H
#define COUPLEDAUX_H

#include "AuxKernel.h"


//Forward Declarations
class CoupledAux;

template<>
InputParameters validParams<CoupledAux>();

/** 
 * Coupled auxiliary value
 */
class CoupledAux : public AuxKernel
{
public:

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  CoupledAux(const std::string & name, InputParameters parameters);

  virtual ~CoupledAux() {}
  
protected:
  virtual Real computeValue();

  int _coupled;
  VariableValue & _coupled_val;
  Real _value;
};

#endif //COUPLEDAUX_H
