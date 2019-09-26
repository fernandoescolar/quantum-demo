namespace qsharp
{
    open Microsoft.Quantum.Intrinsic;

    operation Entanglement(q1: Qubit, q2: Qubit): Unit
    {
        H(q1);
        CNOT(q1, q2);
    }

    operation MakeEntanglement(initial: Result): (Result, Result)
    {
        using (qubits = Qubit[2])
        {
            Set(qubits[0], initial);
            Set(qubits[1], Zero);
            
            Entanglement(qubits[0], qubits[1]);
            
            let res0 = M(qubits[0]);
            let res1 = M(qubits[1]);

            ResetAll(qubits);

            return (res0, res1);
        }
    }
}