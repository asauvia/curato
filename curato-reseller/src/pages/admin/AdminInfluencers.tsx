import { useState } from "react";
import { Link } from "wouter";
import { useAdminListResellers, useAdminUpdateResellerStatus, getAdminListResellersQueryKey, getAdminGetResellerQueryKey } from "@/api-client";
import { useQueryClient } from "@tanstack/react-query";
import { formatCurrency, formatDate, getStatusColor } from "@/lib/utils";
import { Search, Users, ChevronRight } from "lucide-react";
import { toast } from "sonner";

const statusOptions = ["", "Active", "Pending", "Suspended"];

export default function AdminResellers() {
  const [status, setStatus] = useState("");
  const [search, setSearch] = useState("");
  const { data: Resellers, isLoading } = useAdminListResellers({ status: status || undefined, search: search || undefined });
  const qc = useQueryClient();
  const updateStatus = useAdminUpdateResellerStatus();

  const handleStatus = (id: number, newStatus: string) => {
    updateStatus.mutate({ id, data: { status: newStatus } }, {
      onSuccess: () => {
        qc.invalidateQueries({ queryKey: getAdminListResellersQueryKey() });
        toast.success(`Status updated to ${newStatus}`);
      }
    });
  };

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-foreground font-normal tracking-tight text-2xl">Reseller Management</h1>
        <p className="text-muted-foreground text-sm mt-1">{Resellers?.length ?? 0} Resellers registered</p>
      </div>

      <div className="flex flex-col md:flex-row gap-3 mb-5">
        <div className="relative flex-1 max-w-sm">
          <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
          <input value={search} onChange={e => setSearch(e.target.value)} className="w-full pl-9 border border-border rounded-xl bg-card px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-foreground" placeholder="Search Reseller..." />
        </div>
        <div className="flex flex-wrap gap-1 bg-card border border-border rounded-xl p-1 self-start">
          {statusOptions.map(s => (
            <button key={s} onClick={() => setStatus(s)} className={`px-4 py-1.5 rounded-full text-sm font-medium transition-all ${status === s ? "bg-foreground text-background" : "text-muted-foreground hover:bg-muted"}`}>
              {s || "All"}
            </button>
          ))}
        </div>
      </div>

      <div className="bg-card rounded-xl border border-border overflow-hidden">
        <div className="overflow-x-auto w-full">
          <table className="w-full min-w-[800px] text-sm">
            <thead className="bg-muted border-b border-border">
              <tr>
                <th className="text-left px-5 py-3 text-muted-foreground font-medium">Reseller</th>
                <th className="text-left px-5 py-3 text-muted-foreground font-medium">Code</th>
                <th className="text-right px-5 py-3 text-muted-foreground font-medium">Wallet</th>
                <th className="text-right px-5 py-3 text-muted-foreground font-medium">Earnings</th>
                <th className="text-center px-5 py-3 text-muted-foreground font-medium">Orders</th>
                <th className="text-center px-5 py-3 text-muted-foreground font-medium">Status</th>
                <th className="text-center px-5 py-3 text-muted-foreground font-medium">Actions</th>
                <th className="px-5 py-3" />
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {isLoading ? (
                [...Array(5)].map((_, i) => (
                  <tr key={i}><td colSpan={8} className="px-5 py-4"><div className="h-4 bg-muted rounded animate-pulse w-full" /></td></tr>
                ))
              ) : !Resellers?.length ? (
                <tr><td colSpan={8} className="text-center py-12 text-muted-foreground"><Users size={32} className="mx-auto mb-2 opacity-20" /><p>No Resellers found</p></td></tr>
              ) : Resellers.map(inf => (
                <tr key={inf.id} className="hover:bg-muted">
                  <td className="px-5 py-4">
                    <p className="font-medium text-foreground">{inf.name}</p>
                    <p className="text-muted-foreground text-xs">{inf.email}</p>
                  </td>
                  <td className="px-5 py-4 font-mono text-foreground text-xs font-semibold">{inf.ResellerCode}</td>
                  <td className="px-5 py-4 text-right font-medium text-foreground">{formatCurrency(inf.walletBalance)}</td>
                  <td className="px-5 py-4 text-right font-medium text-signal">{formatCurrency(inf.totalEarnings)}</td>
                  <td className="px-5 py-4 text-center text-muted-foreground">{inf.totalOrders}</td>
                  <td className="px-5 py-4 text-center">
                    <span className={`px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(inf.status)}`}>{inf.status}</span>
                  </td>
                  <td className="px-5 py-4 text-center">
                    <select
                      value={inf.status}
                      onChange={e => handleStatus(inf.id, e.target.value)}
                      className="text-xs border border-border rounded-lg px-2 py-1.5 focus:outline-none focus:ring-1 focus:ring-foreground animate-none"
                    >
                      {["Active", "Pending", "Suspended"].map(s => <option key={s}>{s}</option>)}
                    </select>
                  </td>
                  <td className="px-5 py-4">
                    <Link href={`/admin/Resellers/${inf.id}`}>
                      <ChevronRight size={16} className="text-muted-foreground hover:text-foreground cursor-pointer" />
                    </Link>
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
