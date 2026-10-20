import { useState } from "react";
import { Link, useLocation } from "wouter";
import { useLoginReseller, getGetCurrentUserQueryKey } from "@/api-client";
import { useQueryClient } from "@tanstack/react-query";

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [, navigate] = useLocation();
  const qc = useQueryClient();
  const login = useLoginReseller();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    login.mutate({ data: { email, password } }, {
      onSuccess: (data) => {
        if ((data as any).token) {
          localStorage.setItem("auth_token", (data as any).token);
        }
        qc.invalidateQueries({ queryKey: getGetCurrentUserQueryKey() });
        const role = data.user.role;
        if (role === "admin") navigate("/admin");
        else if (role === "vendor") navigate("/vendor/orders");
        else navigate("/dashboard");
      }
    });
  };

  return (
    <div className="min-h-screen bg-background flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        {/* Brand */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-foreground mb-4">
            <span className="text-background font-black text-2xl">O</span>
          </div>
          <h1 className="text-foreground font-normal tracking-tight text-2xl">Curato India</h1>
          <p className="text-muted-foreground text-sm mt-1">Reseller & Reseller Platform</p>
        </div>

        <div className="bg-background rounded-2xl p-8 border border-border shadow-2xl">
          <h2 className="text-foreground font-semibold text-lg mb-6">Sign in to your account</h2>

          {login.error && (
            <div className="mb-4 px-4 py-3 bg-red-500/10 border border-red-500/30 rounded-lg text-red-600 text-sm">
              {(login.error as any)?.data?.error ?? "Invalid credentials"}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-muted-foreground text-sm font-medium mb-1.5">Email address</label>
              <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                required
                className="w-full bg-background border border-border rounded-lg px-4 py-2.5 text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-foreground focus:border-transparent text-sm"
                placeholder="you@example.com"
              />
            </div>
            <div>
              <label className="block text-muted-foreground text-sm font-medium mb-1.5">Password</label>
              <input
                type="password"
                value={password}
                onChange={e => setPassword(e.target.value)}
                required
                className="w-full bg-background border border-border rounded-lg px-4 py-2.5 text-foreground placeholder-muted-foreground focus:outline-none focus:ring-2 focus:ring-foreground focus:border-transparent text-sm"
                placeholder="••••••••"
              />
            </div>
            <button
              type="submit"
              disabled={login.isPending}
              className="w-full bg-foreground hover:bg-foreground/85 disabled:opacity-60 text-background font-semibold py-2.5 rounded-full transition-all text-sm"
            >
              {login.isPending ? "Signing in..." : "Sign in"}
            </button>
          </form>

          <div className="mt-6 pt-5 border-t border-border text-center">
            <p className="text-muted-foreground text-sm">
              New reseller?{" "}
              <Link href="/register" className="text-foreground hover:text-foreground font-medium">
                Create account
              </Link>
            </p>
          </div>

          {/* <div className="mt-4 p-3 bg-background/50 rounded-lg text-xs text-muted-foreground space-y-1">
            <p className="font-medium text-muted-foreground">Demo accounts:</p>
            <p>Admin: admin@asauvia.com / admin123</p>
            <p>Reseller: priya@demo.com / demo123</p>
          </div> */}
        </div>
      </div>
    </div>
  );
}
