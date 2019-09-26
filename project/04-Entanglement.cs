using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace qsharp
{
    public class EntanglementDriver : IDriver
    {
        public void Run(QuantumSimulator qsim)
        {
            var initials = new Result[] { Result.Zero, Result.One };
            foreach (var initial in initials)
            {
                var res = MakeEntanglement.Run(qsim, initial).Result;
                var (res1, res2) = res;
                Console.WriteLine($"{res1} {res2}");
            }
        }
    }
}