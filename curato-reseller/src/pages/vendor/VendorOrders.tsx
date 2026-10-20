import { useListVendorOrders } from "@/api-client";
import { formatCurrency, formatDate, getStatusColor } from "@/lib/utils";
import { ShoppingCart } from "lucide-react";

export default function VendorOrders() {
  const { data: orders, isLoading } = useListVendorOrders();

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-foreground font-normal tracking-tight text-2xl">Vendor Orders</h1>
        <p className="text-muted-foreground text-sm mt-1">All orders with source information</p>
      </div>

      <div className="bg-card rounded-xl border border-border overflow-hidden">
        <div className="overflow-x-auto w-full">
          <table className="w-full min-w-[800px] text-sm">
            <thead className="bg-muted border-b border-border">
              <tr>
                <th className="text-left px-5 py-3 text-muted-foreground font-medium">Order #</th>
                <th className="text-left px-5 py-3 text-muted-foreground font-medium">Customer</th>
                <th className="text-left px-5 py-3 text-muted-foreground font-medium">Product</th>
                <th className="text-right px-5 py-3 text-muted-foreground font-medium">Amount</th>
                <th className="text-center px-5 py-3 text-muted-foreground font-medium">Status</th>
                <th className="text-left px-5 py-3 text-muted-foreground font-medium">Source</th>
                <th className="text-left px-5 py-3 text-muted-foreground font-medium">Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {isLoading ? (
                [...Array(5)].map((_, i) => <tr key={i}><td colSpan={7} className="px-5 py-4"><div className="h-4 bg-muted rounded animate-pulse" /></td></tr>)
              ) : !orders?.length ? (
                <tr><td colSpan={7} className="text-center py-12 text-muted-foreground"><ShoppingCart size={36} className="mx-auto mb-2 opacity-20" /><p>No orders found</p></td></tr>
              ) : orders.map(o => (
                <tr key={o.id} className="hover:bg-muted">
                  <td className="px-5 py-4 font-mono text-xs text-muted-foreground">#{o.id}</td>
                  <td className="px-5 py-4 font-medium text-foreground">{o.customerName}</td>
                  <td className="px-5 py-4 text-foreground">{o.productName}</td>
                  <td className="px-5 py-4 text-right font-bold text-foreground">{formatCurrency(Number(o.amount))}</td>
                  <td className="px-5 py-4 text-center">
                    <span className={`px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(o.status)}`}>{o.status}</span>
                  </td>
                  <td className="px-5 py-4">
                    {o.source === "Reseller Order" ? (
                      <div>
                        <span className="px-2.5 py-0.5 rounded-full text-xs font-medium bg-muted text-foreground border border-border">{o.source}</span>
                        {o.ResellerName && <p className="text-xs text-muted-foreground mt-0.5">{o.ResellerName} ({o.ResellerCode})</p>}
                      </div>
                    ) : (
                      <span className="px-2.5 py-0.5 rounded-full text-xs font-medium bg-muted text-muted-foreground">{o.source}</span>
                    )}
                  </td>
                  <td className="px-5 py-4 text-muted-foreground text-xs">{formatDate(o.createdAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
