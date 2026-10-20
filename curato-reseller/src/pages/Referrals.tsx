import { useListReferralLinks, useGenerateReferralLink, getListReferralLinksQueryKey } from "@/api-client";
import { useQueryClient } from "@tanstack/react-query";
import { formatDate } from "@/lib/utils";
import { Copy, Link2, Share2, MessageCircle, Send } from "lucide-react";
import { toast } from "sonner";

export default function Referrals() {
  const { data: links, isLoading } = useListReferralLinks();

  const getDisplayUrl = (url: string) => {
    if (window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1") {
      return url
        .replace("https://curato.asauvia.com/product/", "http://localhost:5173/product/")
        .replace("https://mycollectionsforyou.com/product/", "http://localhost:5173/product/");
    }
    return url;
  };

  const copy = (url: string) => { navigator.clipboard.writeText(getDisplayUrl(url)); toast.success("Link copied to clipboard!"); };

  const shareWhatsApp = (url: string, name: string) => {
    window.open(`https://wa.me/?text=Check out ${encodeURIComponent(name)} at ${encodeURIComponent(getDisplayUrl(url))}`, "_blank");
  };

  const shareTelegram = (url: string, name: string) => {
    window.open(`https://t.me/share/url?url=${encodeURIComponent(getDisplayUrl(url))}&text=${encodeURIComponent("Check out " + name)}`, "_blank");
  };

  if (isLoading) return (
    <div className="p-8"><div className="animate-pulse space-y-3">{[...Array(4)].map((_, i) => <div key={i} className="h-24 bg-muted rounded-xl" />)}</div></div>
  );

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-foreground font-normal tracking-tight text-2xl">Referral Links</h1>
        <p className="text-muted-foreground text-sm mt-1">Share these links to earn commission on every sale</p>
      </div>

      {!links?.length ? (
        <div className="text-center py-20 text-muted-foreground">
          <Link2 size={48} className="mx-auto mb-4 opacity-20" />
          <p className="font-medium">No referral links yet</p>
          <p className="text-sm mt-1">Add products to your reseller list and generate referral links</p>
        </div>
      ) : (
        <div className="space-y-4">
          {links.map(link => (
            <div key={link.id} className="bg-card rounded-xl border border-border p-5 hover:border-border transition-all">
              <div className="flex items-start justify-between gap-4">
                <div className="flex-1">
                  <h3 className="font-semibold text-foreground">{link.productName}</h3>
                  <div className="flex items-center gap-2 mt-2">
                    <div className="flex-1 bg-muted border border-border rounded-lg px-3 py-2">
                      <p className="text-xs text-muted-foreground mb-0.5">Referral URL</p>
                      <p className="text-sm font-mono text-foreground truncate">{getDisplayUrl(link.fullUrl)}</p>
                    </div>
                    <button onClick={() => copy(link.fullUrl)} className="p-2.5 bg-muted hover:bg-muted rounded-full text-muted-foreground hover:text-foreground transition-all" title="Copy link">
                      <Copy size={16} />
                    </button>
                  </div>
                  <div className="flex items-center gap-2 mt-3">
                    <span className="text-xs font-medium text-muted-foreground">Share:</span>
                    <button onClick={() => shareWhatsApp(link.fullUrl, link.productName)} className="flex items-center gap-1.5 text-xs bg-signal/10 text-signal hover:bg-signal/15 border border-signal/30 px-3 py-1.5 rounded-full font-medium transition-all">
                      <MessageCircle size={13} />
                      WhatsApp
                    </button>
                    <button onClick={() => shareTelegram(link.fullUrl, link.productName)} className="flex items-center gap-1.5 text-xs bg-muted text-foreground hover:bg-muted border border-border px-3 py-1.5 rounded-full font-medium transition-all">
                      <Send size={13} />
                      Telegram
                    </button>
                    <button onClick={() => copy(link.fullUrl)} className="flex items-center gap-1.5 text-xs bg-muted text-foreground hover:bg-muted border border-border px-3 py-1.5 rounded-full font-medium transition-all">
                      <Share2 size={13} />
                      Copy URL
                    </button>
                  </div>
                </div>
                <div className="text-right shrink-0">
                  <div className="grid grid-cols-2 gap-3">
                    <div className="text-center">
                      <p className="text-2xl font-bold text-foreground">{link.clicks}</p>
                      <p className="text-xs text-muted-foreground">Clicks</p>
                    </div>
                    <div className="text-center">
                      <p className="text-2xl font-bold text-foreground">{link.orders}</p>
                      <p className="text-xs text-muted-foreground">Orders</p>
                    </div>
                  </div>
                  <p className="text-xs text-muted-foreground mt-2">{formatDate(link.createdAt)}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
