import { useState } from "react";
import { useListWithdrawals, useGetWallet, useRequestWithdrawal, getListWithdrawalsQueryKey, getGetWalletQueryKey } from "@/api-client";
import { useQueryClient } from "@tanstack/react-query";
import { formatCurrency, formatDate, getStatusColor } from "@/lib/utils";
import { ArrowDownToLine, AlertCircle } from "lucide-react";
import { toast } from "sonner";

export default function Withdrawals() {
  const { data: withdrawals, isLoading } = useListWithdrawals();
  const { data: wallet } = useGetWallet();
  const qc = useQueryClient();
  const request = useRequestWithdrawal();
  const [form, setForm] = useState({ amount: "", bankName: "", accountNumber: "", ifsc: "", upiId: "" });

  const set = (k: keyof typeof form) => (e: React.ChangeEvent<HTMLInputElement>) => setForm(f => ({ ...f, [k]: e.target.value }));

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    request.mutate({ data: { amount: parseFloat(form.amount), bankName: form.bankName, accountNumber: form.accountNumber, ifsc: form.ifsc, upiId: form.upiId || undefined } }, {
      onSuccess: () => {
        qc.invalidateQueries({ queryKey: getListWithdrawalsQueryKey() });
        qc.invalidateQueries({ queryKey: getGetWalletQueryKey() });
        setForm({ amount: "", bankName: "", accountNumber: "", ifsc: "", upiId: "" });
        toast.success("Withdrawal request submitted!");
      }
    });
  };

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-foreground font-normal tracking-tight text-2xl">Withdrawals</h1>
        <p className="text-muted-foreground text-sm mt-1">Request payouts to your bank account</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Form */}
        <div className="lg:col-span-1">
          <div className="bg-card rounded-xl border border-border p-6">
            <div className="mb-5 p-4 bg-muted rounded-lg border border-border">
              <p className="text-xs text-muted-foreground font-medium mb-1">Available Balance</p>
              <p className="text-2xl font-bold text-foreground">{formatCurrency(wallet?.availableBalance ?? 0)}</p>
            </div>
            <div className="flex flex-col gap-1.5 mb-5 text-xs text-muted-foreground bg-muted p-3 rounded-lg">
              <div className="flex items-start gap-2">
                <AlertCircle size={14} className="shrink-0 mt-0.5 text-foreground" />
                <span>Minimum withdrawal: <strong className="text-foreground">₹500</strong></span>
              </div>
              <div className="flex items-start gap-2">
                <AlertCircle size={14} className="shrink-0 mt-0.5 text-foreground" />
                <span>Maximum withdrawal limit: <strong className="text-foreground">₹50,000/day</strong></span>
              </div>
            </div>
            <form onSubmit={handleSubmit} className="space-y-3">
              <div>
                <label className="block text-sm font-medium text-foreground mb-1">Amount (₹)</label>
                <input type="number" value={form.amount} onChange={set("amount")} required min="500" className="w-full border border-border rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-foreground" placeholder="Min ₹500" />
              </div>
              <div>
                <label className="block text-sm font-medium text-foreground mb-1">Bank Name</label>
                <input value={form.bankName} onChange={set("bankName")} required className="w-full border border-border rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-foreground" placeholder="e.g. HDFC Bank" />
              </div>
              <div>
                <label className="block text-sm font-medium text-foreground mb-1">Account Number</label>
                <input value={form.accountNumber} onChange={set("accountNumber")} required className="w-full border border-border rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-foreground" placeholder="Account number" />
              </div>
              <div>
                <label className="block text-sm font-medium text-foreground mb-1">IFSC Code</label>
                <input value={form.ifsc} onChange={set("ifsc")} required className="w-full border border-border rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-foreground" placeholder="e.g. HDFC0001234" />
              </div>
              <div>
                <label className="block text-sm font-medium text-foreground mb-1">UPI ID (optional)</label>
                <input value={form.upiId} onChange={set("upiId")} className="w-full border border-border rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-foreground" placeholder="name@upi" />
              </div>
              {request.error && <p className="text-red-500 text-xs">{(request.error as any)?.data?.error}</p>}
              <button type="submit" disabled={request.isPending} className="w-full bg-foreground hover:bg-foreground/85 disabled:opacity-60 text-background font-semibold py-2.5 rounded-full text-sm mt-1">
                {request.isPending ? "Submitting..." : "Request Withdrawal"}
              </button>
            </form>
          </div>
        </div>

        {/* History */}
        <div className="lg:col-span-2">
          <div className="bg-card rounded-xl border border-border">
            <div className="px-5 py-4 border-b border-border">
              <h2 className="font-semibold text-foreground">Withdrawal History</h2>
            </div>
            {isLoading ? (
              <div className="p-6 animate-pulse space-y-2">{[...Array(3)].map((_, i) => <div key={i} className="h-16 bg-muted rounded-lg" />)}</div>
            ) : !withdrawals?.length ? (
              <div className="text-center py-12 text-muted-foreground">
                <ArrowDownToLine size={36} className="mx-auto mb-3 opacity-20" />
                <p>No withdrawal requests yet</p>
              </div>
            ) : (
              <div className="divide-y divide-border">
                {withdrawals.map(w => (
                  <div key={w.id} className="px-5 py-4 flex items-center justify-between">
                    <div>
                      <p className="font-semibold text-foreground">{formatCurrency(Number(w.amount))}</p>
                      <p className="text-xs text-muted-foreground mt-0.5">{w.bankName} • {w.accountNumber.slice(-4).padStart(w.accountNumber.length, "•")}</p>
                      <p className="text-xs text-muted-foreground">{formatDate(w.requestedAt)}</p>
                    </div>
                    <span className={`px-3 py-1 rounded-full text-xs font-medium ${getStatusColor(w.status)}`}>{w.status}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
