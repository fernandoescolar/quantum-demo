namespace qsharp {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Oracles;
    open Microsoft.Quantum.Characterization;

    operation MakeShor(N : Int) : (Int, Int) 
    {
        if (N % 2 == 0) 
        {
            Message("An even number has been passed; 2 is the factor.");
            return (2, N / 2);
        }

        // 1. Escoja un número pseudo-aleatorio a < N
        let a = RandomInt(N - 2) + 1;
        
        // 2. Compute el mcd(a, N)
        let mcd = GreatestCommonDivisorI(N, a);

        // 2.1. Si el mcd(a, N) ≠ 1, entonces es un factor no trivial de N, así que terminamos
        if (mcd != 1)
        {
            return (mcd, N / mcd);
        }

        // 2.2. utilice el subprograma para encontrar el período para encontrar r
        let r = QuantumShor(a, N);

        // 2.2.1. Si r es impar, vaya de nuevo al paso 1.
        if (r % 2 != 0)
        {
            Message("try again");
            fail "empieza otra vez";
            //return MakeShor(N);
        }

        // 2.2.2. Si ar/2 ≡ -1 (mod N), vaya de nuevo al paso 1
        let halfPower = ExpModI(a, r / 2, N);
        if (halfPower == N - 1) 
        {
            Message("try again");
            fail "empieza otra vez";
            //return MakeShor(N);
        }

        // 2.2.3. Los factores de N son el mcd(ar/2 ± 1, N)
        let factor = MaxI(GreatestCommonDivisorI(halfPower - 1, N), GreatestCommonDivisorI(halfPower + 1, N));
        return (factor, N / factor);        
    }

    ////////////////////////////////////////////////////////////////////////
    // this code bellow is from q# samples from Microsoft github repository
    operation QuantumShor (generator : Int, modulus : Int) : Int {
        // Here we check that the inputs to the EstimatePeriod operation are valid.
        // EqualityFactB(IsCoprimeI(generator, modulus), true, "`generator` and `modulus` must be co-prime");

        // The variable that stores the divisor of the generator period found so far.
        mutable result = 1;

        // Number of bits in the modulus with respect to which we are estimating the period.
        let bitsize = BitSizeI(modulus);

        // The EstimatePeriod operation estimates the period r by finding an
        // approximation k/2^bitsPrecision to a fraction s/r where s is some integer.
        // Note that if s and r have common divisors we will end up recovering a divisor of r
        // and not r itself. However, if we recover enough divisors of r
        // we recover r itself pretty soon.

        // Number of bits of precision with which we need to estimate s/r to recover period r.
        // using continued fractions algorithm.
        let bitsPrecision = 2 * bitsize + 1;

        repeat {

            // The variable that stores numerator of dyadic fraction k/2^bitsPrecision
            // approximating s/r
            mutable dyadicFractionNum = 0;

            // Allocate qubits for the superposition of eigenstates of
            // the oracle that is used in period finding
            using (eigenstateRegister = Qubit[bitsize]) {

                // initialize to '1' all qubits as a little endian integer
                X(eigenstateRegister[0]);
                

                // An oracle of type Microsoft.Quantum.Canon.DiscreteOracle
                // that we are going to use with phase estimation methods below.
                let oracle = DiscreteOracle(OrderFindingOracle(generator, modulus, _, _));

                // Find the numerator of a dyadic fraction that approximates
                // s/r where r is the multiplicative order ( period ) of g
                
                // Use Microsoft.Quantum.Canon.RobustPhaseEstimation to estimate s/r.
                // RobustPhaseEstimation needs only one extra qubit, but requires
                // several calls to the oracle
                let phase = RobustPhaseEstimation(bitsPrecision, oracle, eigenstateRegister);

                // Compute the numerator k of dyadic fraction k/2^bitsPrecision
                // approximating s/r. Note that phase estimation project on the eigenstate
                // corresponding to random s.
                set dyadicFractionNum = Round(((phase * IntAsDouble(2 ^ bitsPrecision)) / 2.0) / PI());
            
                // Return all the qubits used for oracle's eigenstate back to 0 state
                // using Microsoft.Quantum.Canon.ResetAll
                ResetAll(eigenstateRegister);
            }

            // Sometimes we might measure all zeros state in Phase Estimation.
            // This is a failure and we need to start all over.
            if (dyadicFractionNum == 0) {
                fail "We measured 0 for the numerator";
            }

            // This will print our estimate of s/r to the standard output
            // using Microsoft.Quantum.Intrinsic.Message
            Message($"Estimated eigenvalue is {dyadicFractionNum}/2^{bitsPrecision}.");

            // Now we use Microsoft.Quantum.Math.ContinuedFractionConvergentI
            // function to recover s/r from dyadic fraction k/2^bitsPrecision.
            let (numerator, period) = (ContinuedFractionConvergentI(Fraction(dyadicFractionNum, 2 ^ bitsPrecision), modulus))!;

            // ContinuedFractionConvergentI does not guarantee the signs of the numerator
            // and denominator. Here we make sure that both are positive using
            // AbsI.
            let (numeratorAbs, periodAbs) = (AbsI(numerator), AbsI(period));

            // Use Microsoft.Quantum.Intrinsic.Message to output the
            // period divisor and the eigenstate number
            Message($"Estimated divisor of period is {periodAbs}, " + $" we have projected on eigenstate marked by {numeratorAbs}.");

            // Update the result variable by including newly found divisor.
            // Uses Microsoft.Quantum.Math.GreatestCommonDivisorI function from Microsoft.Quantum.Math.
            set result = (periodAbs * result) / GreatestCommonDivisorI(result, periodAbs);
        }
        until (ExpModI(generator, result, modulus) == 1)
        fixup {

            // Above we checked if we have found actual period, or only the divisor of it.
            // If the period was found, loop terminates.

            // If we have not found the period, output message about it to
            // standard output and try again.
            Message("It looks like the period has divisors and we have " + "found only a divisor of the period. Trying again ...");
        }

        // Return found period.
        return result;
    }

    /// # Summary
    /// Interprets `target` as encoding unsigned little-endian integer k
    /// and performs transformation |k⟩ ↦ |gᵖ⋅k mod N ⟩ where
    /// p is `power`, g is `generator` and N is `modulus`.
    operation OrderFindingOracle (generator : Int, modulus : Int, power : Int, target : Qubit[]) : Unit is Adj + Ctl {
        // The oracle we use for order finding essentially wraps
        // Microsoft.Quantum.Canon.ModularMultiplyByConstantLE operation
        // that implements |x⟩ ↦ |x⋅a mod N ⟩.
        // We also use Microsoft.Quantum.Math.ExpModI to compute a by which
        // x must be multiplied.
        // Also note that we interpret target as unsigned integer
        // in little-endian encoding by using Microsoft.Quantum.Canon.LittleEndian
        // type.
        MultiplyByModularInteger(ExpModI(generator, power, modulus), modulus, LittleEndian(target));
    }
}

