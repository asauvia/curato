import { useAdminGetAnalytics } from "@/api-client";
import { formatCurrency } from "@/lib/utils";
import { TrendingUp, MousePointerClick, ShoppingCart, Percent, IndianRupee } from "lucide-react";

export default function AdminAnalytics() {
  const { data, isLoading } = useAdminGetAnalytics();

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-foreground font-normal tracking-tight text-2xl">Referral Analytics</h1>
        <p className="text-muted-foreground text-sm mt-1">Platform-wide referral and sales data</p>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4 mb-8">
        {[
          { label: "Total Clicks", value: String(data?.totalClicks ?? 0), icon: MousePointerClick },
          { label: "Total Orders", value: String(data?.totalOrders ?? 0), icon: ShoppingCart },
          { label: "Conversions", value: String(data?.totalConversions ?? 0), icon: TrendingUp },
          { label: "Conversion Rate", value: `${data?.conversionRate ?? 0}%`, icon: Percent },
          { label: "Total Revenue", value: formatCurrency(data?.totalRevenue ?? 0), icon: IndianRupee },
        ].map(m => (
          <div key={m.label} className="bg-card rounded-xl border border-border p-5">
            <div className="flex items-center justify-between mb-3">
              <p className="text-muted-foreground text-sm font-medium">{m.label}</p>
              <m.icon size={15} className="text-foreground" />
            </div>
            <p className="text-2xl font-bold text-foreground">{m.value}</p>
          </div>
        ))}
      </div>

      <div className="bg-card rounded-xl border border-border overflow-hidden">
        <div className="px-5 py-4 border-b border-border">
          <h2 className="font-semibold text-foreground">Top Products by Revenue</h2>
        </div>
        {isLoading ? (
          <div className="p-6 animate-pulse space-y-2">{[...Array(5)].map((_, i) => <div key={i} className="h-12 bg-muted rounded" />)}</div>
        ) : !data?.topProducts.length ? (
          <div className="text-center py-12 text-muted-foreground"><p>No data yet</p></div>
        ) : (
          <div className="overflow-x-auto w-full">
            <table className="w-full min-w-[800px] text-sm">
              <thead className="bg-muted border-b border-border">
                <tr>
                  <th className="text-left px-5 py-3 text-muted-foreground font-medium">Product</th>
                  <th className="text-right px-5 py-3 text-muted-foreground font-medium">Clicks</th>
                  <th className="text-right px-5 py-3 text-muted-foreground font-medium">Orders</th>
                  <th className="text-right px-5 py-3 text-muted-foreground font-medium">Conv. Rate</th>
                  <th className="text-right px-5 py-3 text-muted-foreground font-medium">Revenue</th>
                  <th className="text-right px-5 py-3 text-muted-foreground font-medium">Profit Paid</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {data.topProducts.map(p => (
                  <tr key={p.productId} className="hover:bg-muted">
                    <td className="px-5 py-4 font-medium text-foreground">{p.productName}</td>
                    <td className="px-5 py-4 text-right text-muted-foreground">{p.clicks}</td>
                    <td className="px-5 py-4 text-right text-muted-foreground">{p.orders}</td>
                    <td className="px-5 py-4 text-right text-muted-foreground">{p.clicks > 0 ? `${Math.round(p.orders / p.clicks * 100)}%` : "0%"}</td>
                    <td className="px-5 py-4 text-right font-medium text-foreground">{formatCurrency(p.revenue)}</td>
                    <td className="px-5 py-4 text-right font-bold text-foreground">{formatCurrency(p.profit)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
