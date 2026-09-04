# cutout.ps1: flood-fill background removal -> 480x760 alpha PNG mascot. Background rule can be a loose "light / pinkish" classifier
# (-Mode light) instead of distance-from-corner-colour (-Mode white), so soft radial gradients go too, and rectangles
# in SOURCE pixel space can be forced transparent (logos, speech bubbles, captions).
# Dark line-art outlines keep the flood fill out of the subject.
#   cutout.ps1 <in> <out> [-Mode white|light] [-Tol 40] [-Soft 18] [-Pad 8] [-Erase "x,y,w,h;x,y,w,h"] [-Crop "x,y,w,h"] [-HoleTol 14] [-HoleMin 40]
# -HoleTol: also clear ENCLOSED background pockets the edge flood fill cannot reach (between hair strands, arm and body).
#   A pocket is a connected region of pixels within HoleTol of the background colour and at least HoleMin px in size.
#   Keep HoleTol tight (10-16). -HoleDark <percent>: a pocket is cleared only when at least that share of its rim
#   is dark ink (luminance < 110) - hair gaps and arm/body gaps are fenced by outlines, a highlight on white cloth is not.
#   -HoleBox "x,y,w,h" (source px): only pockets whose centre lies inside are cleared (e.g. the hair area, leaving white cloth alone).
#   -Debug <png>: writes a source-size overlay - green = pocket cleared, red = candidate rejected, magenta = background.
param([string]$In, [string]$Out, [string]$Mode = 'white', [int]$Tol = 40, [int]$Soft = 18, [int]$Pad = 8, [string]$Erase = '', [string]$Crop = '', [int]$HoleTol = 0, [int]$HoleMin = 40, [int]$HoleDark = 35, [string]$HoleBox = '', [string]$Debug = '')
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System; using System.Drawing; using System.Drawing.Imaging; using System.Collections.Generic; using System.Runtime.InteropServices;
public static class Cut3 {
  public static int[] Run(string src, string dst, string mode, int tol, int soft, int pad, int[] erase, int[] crop, int holeTol, int holeMin, int holeDark, int[] holeBox, string debugPath) {
    Bitmap s0 = new Bitmap(src);
    Bitmap s = s0;
    if (crop != null && crop.Length == 4) { s = s0.Clone(new Rectangle(crop[0],crop[1],crop[2],crop[3]), PixelFormat.Format32bppArgb); }
    int w = s.Width, h = s.Height; Color bg = s.GetPixel(1, 1);
    Rectangle r = new Rectangle(0,0,w,h);
    BitmapData d = s.LockBits(r, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
    byte[] b = new byte[d.Stride*h]; Marshal.Copy(d.Scan0, b, 0, b.Length); s.UnlockBits(d); int st = d.Stride;
    // dist: how far from "background" (0 = certainly bg). white mode: max channel diff from corner colour.
    // light mode: bg = bright, low-saturation-or-pinkish (R high, G,B >= 150, B not much below G).
    int[] dist = new int[w*h];
    for (int y=0;y<h;y++) for (int x=0;x<w;x++){ int o=y*st+x*4; int R=b[o+2], G=b[o+1], B=b[o];
      int v;
      if (mode == "light") {
        int minc = Math.Min(Math.Min(R,G),B);
        int yellow = Math.Max(0, G - B - 15);          // orange/yellow/skin -> not bg
        v = Math.Max(Math.Max(0, 255 - R) , Math.Max(0, 190 - minc));
        v = Math.Max(v, yellow * 3);
      } else {
        v = Math.Max(Math.Max(Math.Abs(R-bg.R), Math.Abs(G-bg.G)), Math.Abs(B-bg.B));
      }
      dist[y*w+x] = v; }
    bool[] isBg = new bool[w*h];
    if (erase != null) for (int k=0;k+3<erase.Length;k+=4) for (int y=Math.Max(0,erase[k+1]); y<Math.Min(h,erase[k+1]+erase[k+3]); y++) for (int x=Math.Max(0,erase[k]); x<Math.Min(w,erase[k]+erase[k+2]); x++) { isBg[y*w+x]=true; dist[y*w+x]=0; }
    Queue<int> q = new Queue<int>();
    for (int x=0;x<w;x++){ q.Enqueue(x); q.Enqueue((h-1)*w+x);} for (int y=0;y<h;y++){ q.Enqueue(y*w); q.Enqueue(y*w+w-1);}
    // erased rectangles also seed the fill
    for (int i=0;i<w*h;i++) if (isBg[i]) { isBg[i]=false; q.Enqueue(i); }
    while (q.Count>0){ int i=q.Dequeue(); if (isBg[i]||dist[i]>tol) continue; isBg[i]=true; int x=i%w, y=i/w;
      if (x>0) q.Enqueue(i-1); if (x<w-1) q.Enqueue(i+1); if (y>0) q.Enqueue(i-w); if (y<h-1) q.Enqueue(i+w); }
    if (erase != null) for (int k=0;k+3<erase.Length;k+=4) for (int y=Math.Max(0,erase[k+1]); y<Math.Min(h,erase[k+1]+erase[k+3]); y++) for (int x=Math.Max(0,erase[k]); x<Math.Min(w,erase[k]+erase[k+2]); x++) isBg[y*w+x]=true;
    int holes = 0, holePx = 0;
    byte[] debug = null; if (!string.IsNullOrEmpty(debugPath)) debug = new byte[w*h];
    if (holeTol > 0) {
      // enclosed pockets: connected components of near-background pixels not reached from the edges
      bool[] seen = new bool[w*h]; List<int> comp = new List<int>();
      for (int s0i=0;s0i<w*h;s0i++){ if (isBg[s0i]||seen[s0i]||dist[s0i]>holeTol) continue;
        comp.Clear(); Queue<int> q2 = new Queue<int>(); q2.Enqueue(s0i); seen[s0i]=true;
        while (q2.Count>0){ int i=q2.Dequeue(); comp.Add(i); int x=i%w, y=i/w;
          int[] nb = { x>0?i-1:-1, x<w-1?i+1:-1, y>0?i-w:-1, y<h-1?i+w:-1 };
          foreach (int j in nb) if (j>=0 && !seen[j] && !isBg[j] && dist[j]<=holeTol) { seen[j]=true; q2.Enqueue(j); } }
        if (comp.Count < holeMin) continue;
        // grow the pocket outward through the soft anti-aliased rim (dist <= tol), tentatively
        List<int> grown = new List<int>(comp); bool[] tmp = new bool[w*h];
        Queue<int> q3 = new Queue<int>(); foreach (int i in comp) { tmp[i]=true; q3.Enqueue(i); }
        while (q3.Count>0){ int i=q3.Dequeue(); int x=i%w, y=i/w;
          int[] nb = { x>0?i-1:-1, x<w-1?i+1:-1, y>0?i-w:-1, y<h-1?i+w:-1 };
          foreach (int j in nb) if (j>=0 && !tmp[j] && !isBg[j] && dist[j]<=tol) { tmp[j]=true; grown.Add(j); q3.Enqueue(j); } }
        // a real pocket is fenced by ink outlines (hair, arm contour); a highlight on white cloth is fenced by
        // light fabric. Look at the subject pixels just outside the grown pocket.
        int rim = 0, rimDark = 0;
        foreach (int i in grown) { int x=i%w, y=i/w;
          int[] nb = { x>0?i-1:-1, x<w-1?i+1:-1, y>0?i-w:-1, y<h-1?i+w:-1 };
          foreach (int j in nb) if (j>=0 && !tmp[j] && !isBg[j]) { rim++; int o=(j/w)*st+(j%w)*4; int lum=(b[o+2]*299+b[o+1]*587+b[o]*114)/1000; if (lum<110) rimDark++; } }
        int pct = rim>0 ? rimDark*100/rim : 0;
        bool inBox = false;   // inside the box the rim rule is waived; outside it still applies
        if (holeBox != null && holeBox.Length == 4) { long sx=0, sy=0; foreach (int i in comp) { sx += i%w; sy += i/w; }
          int cx=(int)(sx/comp.Count), cy=(int)(sy/comp.Count); inBox = cx>=holeBox[0] && cx<holeBox[0]+holeBox[2] && cy>=holeBox[1] && cy<holeBox[1]+holeBox[3]; }
        bool take = inBox || pct >= holeDark;
        if (debug != null) foreach (int i in comp) debug[i] = take ? (byte)1 : (byte)2;
        if (take) { holes++; holePx += comp.Count; foreach (int i in grown) isBg[i]=true; } }
    }
    if (debug != null) {
      // overlay in SOURCE pixel space: green = pocket cleared, red = pocket candidate rejected, magenta = background
      Bitmap dbg = new Bitmap(w,h,PixelFormat.Format24bppRgb);
      for (int y=0;y<h;y++) for (int x=0;x<w;x++){ int i=y*w+x, o=y*st+x*4;
        Color c0 = Color.FromArgb(b[o+2],b[o+1],b[o]);
        if (debug[i]==1) c0 = Color.FromArgb(0,220,0); else if (debug[i]==2) c0 = Color.FromArgb(230,0,0); else if (isBg[i]) c0 = Color.FromArgb(255,0,255);
        dbg.SetPixel(x,y,c0); }
      dbg.Save(debugPath, ImageFormat.Png); dbg.Dispose();
    }
    Bitmap o2 = new Bitmap(w,h,PixelFormat.Format32bppArgb);
    BitmapData od = o2.LockBits(r, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
    byte[] ob = new byte[od.Stride*h]; int minX=w,minY=h,maxX=0,maxY=0;
    for (int y=0;y<h;y++) for (int x=0;x<w;x++){ int i=y*w+x, o=y*st+x*4, p=y*od.Stride+x*4; int a=255;
      if (isBg[i]) a=0; else {
        bool edge = (x>0&&isBg[i-1])||(x<w-1&&isBg[i+1])||(y>0&&isBg[i-w])||(y<h-1&&isBg[i+w]);
        if (edge) a = Math.Min(255, 255*dist[i]/Math.Max(1,tol+soft)); }
      if (a>0){ if(x<minX)minX=x; if(x>maxX)maxX=x; if(y<minY)minY=y; if(y>maxY)maxY=y; }
      ob[p]=b[o]; ob[p+1]=b[o+1]; ob[p+2]=b[o+2]; ob[p+3]=(byte)a; }
    Marshal.Copy(ob,0,od.Scan0,ob.Length); o2.UnlockBits(od);
    int cw=maxX-minX+1, ch=maxY-minY+1; double sc=Math.Min((480.0-2*pad)/cw,(760.0-2*pad)/ch);
    int dw=(int)(cw*sc), dh=(int)(ch*sc);
    Bitmap c = new Bitmap(480,760,PixelFormat.Format32bppArgb);
    using (Graphics g = Graphics.FromImage(c)) { g.Clear(Color.Transparent);
      g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
      g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;
      g.CompositingQuality = System.Drawing.Drawing2D.CompositingQuality.HighQuality;
      g.DrawImage(o2, new Rectangle((480-dw)/2,(760-dh)/2,dw,dh), new Rectangle(minX,minY,cw,ch), GraphicsUnit.Pixel); }
    c.Save(dst, ImageFormat.Png); c.Dispose(); o2.Dispose(); s.Dispose(); if (s != s0) s0.Dispose();
    return new int[]{w,h,minX,minY,maxX,maxY,dw,dh,holes,holePx};
  }
}
"@
$er = $null; if ($Erase) { $er = [int[]]@(($Erase -split '[;,]') | ForEach-Object { [int]$_ }) }
$cr = $null; if ($Crop)  { $cr = [int[]]@(($Crop  -split ',')    | ForEach-Object { [int]$_ }) }
$hb = $null; if ($HoleBox) { $hb = [int[]]@(($HoleBox -split ',') | ForEach-Object { [int]$_ }) }
$r = [Cut3]::Run($In, $Out, $Mode, $Tol, $Soft, $Pad, $er, $cr, $HoleTol, $HoleMin, $HoleDark, $hb, $Debug)
"source $($r[0])x$($r[1])  bbox x=$($r[2])..$($r[4]) y=$($r[3])..$($r[5])  -> $($r[6])x$($r[7]) on 480x760  ($Mode tol=$Tol holeTol=${HoleTol}: $($r[8]) pockets / $($r[9]) px cleared)"
