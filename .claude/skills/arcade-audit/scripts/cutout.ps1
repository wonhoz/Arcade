# cutout3: like cutout2 but (a) background rule can be a loose "light / pinkish" classifier
# instead of distance-from-corner-colour, so soft radial gradients go too, and (b) rectangles
# in SOURCE pixel space can be forced transparent (logos, speech bubbles, captions).
# Dark line-art outlines keep the flood fill out of the subject.
#   cutout3.ps1 <in> <out> [-Mode white|light] [-Tol 40] [-Soft 18] [-Pad 8] [-Erase "x,y,w,h;x,y,w,h"] [-Crop "x,y,w,h"]
param([string]$In, [string]$Out, [string]$Mode = 'white', [int]$Tol = 40, [int]$Soft = 18, [int]$Pad = 8, [string]$Erase = '', [string]$Crop = '')
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System; using System.Drawing; using System.Drawing.Imaging; using System.Collections.Generic; using System.Runtime.InteropServices;
public static class Cut3 {
  public static int[] Run(string src, string dst, string mode, int tol, int soft, int pad, int[] erase, int[] crop) {
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
    return new int[]{w,h,minX,minY,maxX,maxY,dw,dh};
  }
}
"@
$er = $null; if ($Erase) { $er = [int[]]@(($Erase -split '[;,]') | ForEach-Object { [int]$_ }) }
$cr = $null; if ($Crop)  { $cr = [int[]]@(($Crop  -split ',')    | ForEach-Object { [int]$_ }) }
$r = [Cut3]::Run($In, $Out, $Mode, $Tol, $Soft, $Pad, $er, $cr)
"source $($r[0])x$($r[1])  bbox x=$($r[2])..$($r[4]) y=$($r[3])..$($r[5])  -> $($r[6])x$($r[7]) on 480x760  ($Mode tol=$Tol)"
