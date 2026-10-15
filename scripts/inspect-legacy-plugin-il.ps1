param(
    [string]$FrostyInstall = '.\FrostyToolsuite-FIFA17editionv3fixed\FrostyToolsuite-FIFA17editionv3fixed'
)

# Read-only IL listing for the locally installed Legacy BIG plugin. This does
# not invoke the methods or modify game, project, or mod files.
$ErrorActionPreference = 'Stop'
$FrostyInstall = (Resolve-Path -LiteralPath $FrostyInstall).Path
foreach ($name in 'FrostySdk.dll', 'FrostyHash.dll', 'FrostyCore.dll') {
    [void][Reflection.Assembly]::LoadFrom((Join-Path $FrostyInstall $name))
}
$pluginPath = Join-Path $FrostyInstall 'Plugins\Fifa\LegacyBigFilePlugin.dll'
$assembly = [Reflection.Assembly]::LoadFrom($pluginPath)

Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Reflection.Emit;
using System.Text;

public static class LocalIlListing
{
    static readonly Dictionary<ushort, OpCode> Codes = BuildCodes();
    static Dictionary<ushort, OpCode> BuildCodes()
    {
        var d = new Dictionary<ushort, OpCode>();
        foreach (var f in typeof(OpCodes).GetFields(BindingFlags.Public | BindingFlags.Static))
            if (f.GetValue(null) is OpCode op) d[(ushort)op.Value] = op;
        return d;
    }
    static int I4(byte[] b, ref int p) { int v=BitConverter.ToInt32(b,p); p+=4; return v; }
    static long I8(byte[] b, ref int p) { long v=BitConverter.ToInt64(b,p); p+=8; return v; }
    static string Resolve(Module m, int token, MethodBase context)
    {
        try { return m.ResolveMember(token, context.DeclaringType?.GetGenericArguments(), context.IsGenericMethod ? context.GetGenericArguments() : null)?.ToString() ?? "<null>"; }
        catch { try { return m.ResolveString(token); } catch { return "token 0x"+token.ToString("X8"); } }
    }
    public static string Dump(MethodBase method)
    {
        var body=method.GetMethodBody(); if(body==null) return "<no method body>";
        byte[] b=body.GetILAsByteArray(); int p=0; var s=new StringBuilder();
        while(p<b.Length)
        {
            int at=p; ushort v=b[p++]; if(v==0xFE) v=(ushort)(0xFE00|b[p++]);
            if(!Codes.TryGetValue(v,out OpCode op)) { s.AppendLine(at.ToString("X4")+": <unknown>"); continue; }
            string arg="";
            switch(op.OperandType)
            {
                case OperandType.InlineNone: break;
                case OperandType.ShortInlineI: arg=((sbyte)b[p++]).ToString(); break;
                case OperandType.InlineI: arg=I4(b,ref p).ToString(); break;
                case OperandType.InlineI8: arg=I8(b,ref p).ToString(); break;
                case OperandType.ShortInlineR: arg=BitConverter.ToSingle(b,p).ToString("R"); p+=4; break;
                case OperandType.InlineR: arg=BitConverter.ToDouble(b,p).ToString("R"); p+=8; break;
                case OperandType.ShortInlineVar: arg=b[p++].ToString(); break;
                case OperandType.InlineVar: arg=BitConverter.ToUInt16(b,p).ToString(); p+=2; break;
                case OperandType.ShortInlineBrTarget: { sbyte d=(sbyte)b[p++]; arg="IL_"+(p+d).ToString("X4"); break; }
                case OperandType.InlineBrTarget: { int d=I4(b,ref p); arg="IL_"+(p+d).ToString("X4"); break; }
                case OperandType.InlineSwitch: { int n=I4(b,ref p); int baseAt=p+4*n; var xs=new List<string>(); for(int i=0;i<n;i++) xs.Add("IL_"+(baseAt+I4(b,ref p)).ToString("X4")); arg=string.Join(", ",xs); break; }
                case OperandType.InlineString: { int t=I4(b,ref p); try { arg="\""+method.Module.ResolveString(t)+"\""; } catch { arg="token 0x"+t.ToString("X8"); } break; }
                case OperandType.InlineField: case OperandType.InlineMethod: case OperandType.InlineType: case OperandType.InlineTok: case OperandType.InlineSig:
                    { int t=I4(b,ref p); arg=Resolve(method.Module,t,method); break; }
                default: arg="<"+op.OperandType+">"; break;
            }
            s.Append("IL_").Append(at.ToString("X4")).Append(": ").Append(op.Name);
            if(arg.Length>0) s.Append(' ').Append(arg);
            s.AppendLine();
        }
        return s.ToString();
    }
}
'@

$flags = [Reflection.BindingFlags]'Public,NonPublic,Instance,Static,DeclaredOnly'
$type = $assembly.GetType('LegacyBigFilePlugin.LegacyBigFileEditor', $true)
foreach ($methodName in 'LegacyTextEditor_Loaded', 'DecompressEAHD', 'ReconstructBIG') {
    $method = $type.GetMethods($flags) | Where-Object Name -EQ $methodName | Select-Object -First 1
    "===== $($method.DeclaringType.FullName).$($method.Name) ====="
    "Signature: $method"
    [LocalIlListing]::Dump($method)
}

$core = [Reflection.Assembly]::LoadFrom((Join-Path $FrostyInstall 'FrostyCore.dll'))
$handlerType = $core.GetType('Frosty.Core.Handlers.LegacyCustomActionHandler', $true)
foreach ($methodName in 'SaveToMod', 'SaveToProject', 'LoadFromProject', 'Modify', 'GetResourceActions') {
    $method = $handlerType.GetMethods($flags) | Where-Object Name -EQ $methodName | Select-Object -First 1
    if ($null -eq $method) { continue }
    "===== $($method.DeclaringType.FullName).$($method.Name) ====="
    "Signature: $method"
    [LocalIlListing]::Dump($method)
}
