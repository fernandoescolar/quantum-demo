using System;
using Microsoft.Quantum.Simulation.Simulators;

namespace qsharp
{
    public class ShorDriver : IDriver
    {
        public void Run(QuantumSimulator qsim)
        {
            int numberToFactor = 15;
            int nTrials = 100;
            Console.WriteLine($"Factoring {numberToFactor}");
            for (int i = 0; i < nTrials; ++i)
            {
                using (QuantumSimulator sim = new QuantumSimulator())
                {
                    try
                    {
                        // Compute the factors
                        (long factor1, long factor2) = MakeShor.Run(sim, numberToFactor).Result;
                        Console.WriteLine($"Factors are {factor1} and {factor2}");
                        return;
                    } 
                    catch(Exception)
                    {
                        Console.WriteLine($"retry");
                    }
                }
            }
        }
    }
}