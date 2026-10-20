import { useRoute } from "wouter";
import { useAdminGetReseller } from "@/api-client";
import { formatCurrency, formatDate, getStatusColor } from "@/lib/utils";
import { ArrowLeft, User } from "lucide-react";
import { Link } from "wouter";

export default function AdminResellerDetail() {
  const [, params] = useRoute("/admin/Resellers/:id");
  const id = parseInt(params?.id ?? "0", 10);
  const { data: inf, isLoading } = useAdminGetReseller(id);

  if (isLoading) return <div className="p-8"><div className="animate-pulse space-y-4"><div className="h-8 bg-muted rounded w-48" /><div className="h-32 bg-muted rounded-xl" /></div></div>;
  if (!inf) return <div className="p-8 text-muted-foreground">Reseller not found</div>;

  return (
    <div className="p-8 max-w-3xl">
      <Link href="/admin/Resellers">
        <div className="flex items-center gap-2 text-muted-foreground hover:text-foreground text-sm mb-6 cursor-pointer">
          <ArrowLeft size={16} />
          Back to Resellers
        </div>
      </Link>

      <div className="bg-card rounded-xl border border-border p-6 mb-6">
        <div className="flex items-center gap-4 mb-5">
          <div className="w-14 h-14 rounded-xl bg-muted border-2 border-border flex items-center justify-center">
            <span className="text-foreground font-black text-xl">{inf.name.charAt(0)}</span>
          </div>
          <div>
            <h1 className="text-foreground font-normal tracking-tight text-xl">{inf.name}</h1>
            <p className="text-muted-foreground text-sm">{inf.email} • {inf.mobile}</p>
            <div className="flex items-center gap-2 mt-1">
              <span className="font-mono text-foreground text-xs font-semibold bg-muted border border-border px-2 py-0.5 rounded">{inf.ResellerCode}</span>
              <span className={`text-xs font-medium px-2 py-0.5 rounded ${getStatusColor(inf.status)}`}>{inf.status}</span>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 border-t pt-5">
          {[
            { label: "Wallet Balance", value: formatCurrency(inf.walletBalance) },
            { label: "Total Earnings", value: formatCurrency(inf.totalEarnings) },
            { label: "Total Withdrawn", value: formatCurrency(inf.totalWithdrawn) },
            { label: "Total Orders", value: String(inf.totalOrders) },
          ].map(s => (
            <div key={s.label} className="text-center">
              <p className="text-muted-foreground text-xs font-medium">{s.label}</p>
              <p className="text-foreground font-bold text-lg mt-1">{s.value}</p>
            </div>
          ))}
        </div>
      </div>

      <div className="bg-card rounded-xl border border-border p-5">
        <h2 className="font-semibold text-foreground mb-3">Account Information</h2>
        <dl className="grid grid-cols-2 gap-3 text-sm">
          <div><dt className="text-muted-foreground">Member Since</dt><dd className="font-medium text-foreground mt-0.5">{formatDate(inf.createdAt)}</dd></div>
          <div><dt className="text-muted-foreground">Products Shared</dt><dd className="font-medium text-foreground mt-0.5">{inf.productsShared}</dd></div>
          <div><dt className="text-muted-foreground">Reseller ID</dt><dd className="font-mono text-foreground mt-0.5">#{inf.id}</dd></div>
          <div><dt className="text-muted-foreground">User ID</dt><dd className="font-mono text-foreground mt-0.5">#{inf.userId}</dd></div>
        </dl>
      </div>
    </div>
  );
}
