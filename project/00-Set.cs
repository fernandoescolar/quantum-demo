using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace qsharp
{
    public class SetDriver : IDriver
    {
        public void Run(QuantumSimulator qsim)
        {
            var initials = new Result[] { Result.Zero, Result.One };
            foreach (var initial in initials)
            {
                var res = TestSet.Run(qsim, 1000, initial).Result;
                var (numZeros, numOnes) = res;
                Console.WriteLine($"{initial,-4}-> Zeros: {numZeros,-4}, Ones: {numOnes,-4}");
            }
        }
    }
}