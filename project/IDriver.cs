using Microsoft.Quantum.Simulation.Simulators;

namespace qsharp
{
    public interface IDriver
    {
        void Run(QuantumSimulator qsim);
    }
}