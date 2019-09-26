namespace qsharp
{
    open Microsoft.Quantum.Intrinsic;

    operation MeasureAll(): (Result, Result, Result)
    {
        using (qubits = Qubit[1])
        {
            H(qubits[0]);
            
            let resZ = Measure([PauliZ], qubits);
            let resY = Measure([PauliY], qubits);
            let resX = Measure([PauliX], qubits);
            
            ResetAll(qubits);

            return (resZ, resY, resX);
        }
    }
}
