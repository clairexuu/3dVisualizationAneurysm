function V_smooth = laplacian_smooth(V, F, iterations, alpha)
    V_smooth = V;
    for i = 1:iterations
        A = sparse(size(V,1), size(V,1));
        for j = 1:size(F,1)
            for k = 1:3
                v1 = F(j,k);
                v2 = F(j,mod(k,3)+1);
                A(v1,v2) = 1;
                A(v2,v1) = 1;
            end
        end
        D = spdiags(sum(A,2), 0, size(A,1), size(A,2));
        L = D \ A;
        V_smooth = (1 - alpha) * V_smooth + alpha * L * V_smooth;
    end
end
