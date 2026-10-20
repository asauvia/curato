import { useState } from "react";
import { useAdminListWithdrawals, useAdminUpdateWithdrawal, getAdminListWithdrawalsQueryKey } from "@/api-client";
import { useQueryClient } from "@tanstack/react-query";
import { formatCurrency, formatDate, getStatusColor } from "@/lib/utils";
import { CreditCard } from "lucide-react";
import { toast } from "sonner";

const statusFilters = ["", "Pending", "Approved", "Rejected", "Paid"];

export default function AdminWithdrawals() {
  const [status, setStatus] = useState("Pending");
  const { data: withdrawals, isLoading } = useAdminListWithdrawals({ status: status || undefined });
  const qc = useQueryClient();
  const update = useAdminUpdateWithdrawal();

  const handleAction = (id: number, newStatus: string) => {
    update.mutate({ id, data: { status: newStatus } }, {
      onSuccess: () => {
        qc.invalidateQueries({ queryKey: getAdminListWithdrawalsQueryKey() });
        toast.success(`Withdrawal ${newStatus.toLowerCase()}`);
      }
    });
  };

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-foreground font-normal tracking-tight text-2xl">Withdrawal Requests</h1>
        <p className="text-muted-foreground text-sm mt-1">Review and process Reseller withdrawal requests</p>
      </div>

      <div className="flex flex-wrap gap-1 bg-card border border-border rounded-xl p-1 mb-5 w-fit">
        {statusFilters.map(s => (
          <button key={s} onClick={() => setStatus(s)} className={`px-4 py-1.5 rounded-full text-sm font-medium transition-all ${status === s ? "bg-foreground text-background" : "text-muted-foreground hover:bg-muted"}`}>
            {s || "All"}
          </button>
        ))}
      </div>

      <div className="bg-card rounded-xl border border-border overflow-hidden">
        <div className="overflow-x-auto w-full">
          <table className="w-full min-w-[800px] text-sm">
            <thead className="bg-muted border-b border-border">
              <tr>
                <th className="text-left px-5 py-3 text-muted-foreground font-medium">Reseller</th>
                <th className="text-right px-5 py-3 text-muted-foreground font-medium">Amount</th>
                <th className="text-left px-5 py-3 text-muted-foreground font-medium">Bank Details</th>
                <th className="text-left px-5 py-3 text-muted-foreground font-medium">Requested</th>
                <th className="text-center px-5 py-3 text-muted-foreground font-medium">Status</th>
                <th className="text-center px-5 py-3 text-muted-foreground font-medium">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {isLoading ? (
                [...Array(3)].map((_, i) => <tr key={i}><td colSpan={6} className="px-5 py-4"><div className="h-4 bg-muted rounded animate-pulse" /></td></tr>)
              ) : !withdrawals?.length ? (
                <tr><td colSpan={6} className="text-center py-12 text-muted-foreground"><CreditCard size={32} className="mx-auto mb-2 opacity-20" /><p>No {status.toLowerCase()} withdrawals</p></td></tr>
              ) : withdrawals.map(w => (
                <tr key={w.id} className="hover:bg-muted">
                  <td className="px-5 py-4">
                    <p className="font-medium text-foreground">{w.ResellerName ?? "Reseller #" + w.ResellerId}</p>
                    <p className="text-muted-foreground text-xs">ID: #{w.ResellerId}</p>
                  </td>
                  <td className="px-5 py-4 text-right font-bold text-foreground text-base">{formatCurrency(Number(w.amount))}</td>
                  <td className="px-5 py-4">
                    <p className="text-foreground font-medium text-xs">{w.bankName}</p>
                    <p className="text-muted-foreground text-xs">IFSC: {w.ifsc}</p>
                    {w.upiId && <p className="text-muted-foreground text-xs">UPI: {w.upiId}</p>}
                  </td>
                  <td className="px-5 py-4 text-muted-foreground text-xs">{formatDate(w.requestedAt)}</td>
                  <td className="px-5 py-4 text-center">
                    <span className={`px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(w.status)}`}>{w.status}</span>
                  </td>
                  <td className="px-5 py-4 text-center">
                    <div className="flex justify-center gap-1.5">
                      {w.status === "Pending" && (
                        <>
                          <button onClick={() => handleAction(w.id, "Approved")} className="px-3 py-1.5 bg-muted text-foreground border border-border hover:bg-muted text-xs font-medium rounded-full transition-all cursor-pointer">Approve</button>
                          <button onClick={() => handleAction(w.id, "Rejected")} className="px-3 py-1.5 bg-background text-destructive border border-destructive/30 hover:bg-destructive/10 text-xs font-medium rounded-full transition-all cursor-pointer">Reject</button>
                        </>
                      )}
                      {w.status === "Approved" && (
                        <button onClick={() => handleAction(w.id, "Paid")} className="px-3 py-1.5 bg-signal/10 text-signal border border-signal/30 hover:bg-signal/15 text-xs font-medium rounded-full transition-all cursor-pointer">Mark Paid</button>
                      )}
                      {(w.status === "Paid" || w.status === "Rejected") && (
                        <span className="text-muted-foreground text-xs">Done</span>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
