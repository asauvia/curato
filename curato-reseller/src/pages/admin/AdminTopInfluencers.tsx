import { useAdminGetTopResellers } from "@/api-client";
import { formatCurrency } from "@/lib/utils";
import { Award } from "lucide-react";

export default function AdminTopResellers() {
  const { data: Resellers, isLoading } = useAdminGetTopResellers();

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-foreground font-normal tracking-tight text-2xl">Top Performers</h1>
        <p className="text-muted-foreground text-sm mt-1">Leaderboard ranked by total earnings</p>
      </div>

      <div className="bg-card rounded-xl border border-border overflow-hidden">
        <div className="overflow-x-auto w-full">
          <table className="w-full min-w-[800px] text-sm">
            <thead className="bg-muted border-b border-border">
              <tr>
                <th className="text-left px-5 py-3 text-muted-foreground font-medium">Rank</th>
                <th className="text-left px-5 py-3 text-muted-foreground font-medium">Reseller</th>
                <th className="text-right px-5 py-3 text-muted-foreground font-medium">Total Earnings</th>
                <th className="text-right px-5 py-3 text-muted-foreground font-medium">Orders</th>
                <th className="text-right px-5 py-3 text-muted-foreground font-medium">Clicks</th>
                <th className="text-right px-5 py-3 text-muted-foreground font-medium">Conv. Rate</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {isLoading ? (
                [...Array(5)].map((_, i) => <tr key={i}><td colSpan={6} className="px-5 py-4"><div className="h-4 bg-muted rounded animate-pulse" /></td></tr>)
              ) : !Resellers?.length ? (
                <tr><td colSpan={6} className="text-center py-12 text-muted-foreground"><Award size={36} className="mx-auto mb-2 opacity-20" /><p>No Resellers yet</p></td></tr>
              ) : Resellers.map((inf, i) => (
                <tr key={inf.id} className={`hover:bg-muted ${i < 3 ? "bg-muted/30" : ""}`}>
                  <td className="px-5 py-4">
                    <div className={`w-7 h-7 rounded-full flex items-center justify-center font-bold text-xs ${i === 0 ? "bg-foreground text-background" : i === 1 ? "bg-border text-foreground" : i === 2 ? "bg-muted-foreground text-background" : "bg-muted text-muted-foreground"}`}>
                      {i + 1}
                    </div>
                  </td>
                  <td className="px-5 py-4">
                    <p className="font-semibold text-foreground">{inf.name}</p>
                    <p className="text-muted-foreground text-xs font-mono">{inf.ResellerCode}</p>
                  </td>
                  <td className="px-5 py-4 text-right font-bold text-foreground">{formatCurrency(inf.totalEarnings)}</td>
                  <td className="px-5 py-4 text-right text-foreground font-medium">{inf.totalOrders}</td>
                  <td className="px-5 py-4 text-right text-muted-foreground">{inf.totalClicks}</td>
                  <td className="px-5 py-4 text-right text-muted-foreground">{inf.conversionRate}%</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
