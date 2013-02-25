#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# for autojump

import os,sys

LIST_POLYPHONE={ u"龟":u"jgq", u"咯":u"gkl", u"轧":u"gyz", u"单":u"dcs",
        u"腌":u"ay", u"阿":u"ae", u"艾":u"ay", u"扒":u"bp", u"膀":u"bp",
        u"磅":u"bp", u"堡":u"bp", u"刨":u"bp", u"暴":u"bp", u"泌":u"bm",
        u"辟":u"bp", u"扁":u"bp", u"便":u"bp", u"便":u"pb", u"骠":u"bp",
        u"泊":u"bp", u"藏":u"cz", u"曾":u"cz", u"禅":u"cs", u"裳":u"cs",
        u"剿":u"cj", u"嘲":u"cz", u"车":u"cj", u"铛":u"cd", u"乘":u"cs",
        u"澄":u"cd", u"匙":u"cs", u"臭":u"cx", u"畜":u"cx", u"幢":u"cz",
        u"椎":u"cz", u"兹":u"cz", u"伺":u"cs", u"枞":u"cz", u"攒":u"cz",
        u"撮":u"cz", u"沓":u"dt", u"沓":u"dt", u"叨":u"dt", u"钿":u"dt",
        u"调":u"dt", u"囤":u"dt", u"否":u"fp", u"脯":u"fp", u"芥":u"gj",
        u"扛":u"gk", u"革":u"gj", u"给":u"gj", u"颈":u"gj", u"枸":u"gj",
        u"谷":u"gy", u"鹄":u"gh", u"纶":u"gl", u"莞":u"gw", u"桧":u"gh",
        u"咳":u"hk", u"吭":u"hk", u"行":u"hx", u"巷":u"hx", u"合":u"hg",
        u"红":u"hg", u"虹":u"hj", u"会":u"hk", u"稽":u"jq", u"矜":u"jq",
        u"稽":u"jq", u"缉":u"jq", u"亟":u"jq", u"茄":u"jq", u"侥":u"jy",
        u"缴":u"jz", u"解":u"jx", u"趄":u"qj", u"咀":u"jz", u"卡":u"kq",
        u"壳":u"kq", u"溃":u"kh", u"括":u"kg", u"蔓":u"mw", u"秘":u"mb",
        u"粘":u"nz", u"拗":u"na", u"弄":u"nl", u"炮":u"pb", u"屏":u"pb",
        u"曝":u"pb", u"瀑":u"pb", u"栖":u"qx", u"蹊":u"qx", u"奇":u"qj",
        u"荨":u"qx", u"纤":u"qx", u"强":u"qj", u"圈":u"qj", u"葚":u"sr",
        u"厦":u"sx", u"省":u"sx", u"识":u"sz", u"属":u"sz", u"忪":u"sz",
        u"宿":u"sx", u"汤":u"st", u"提":u"td", u"圩":u"wx", u"尾":u"wy",
        u"尉":u"wy", u"系":u"xj", u"虾":u"xh", u"吓":u"xh", u"校":u"xj",
        u"吁":u"xy", u"叶":u"yx", u"遗":u"yw", u"乐":u"yl", u"颤":u"zc",
        u"殖":u"zs" }

LIST_CHARS={ u"～":u"~", u"！":u"!", u"＠":u"@", u"＃":u"#", u"＄":u"$",
        u"％":u"%", u"＆":u"&", u"＊":u"*", u"（":u"(", u"）":u")", u"＿":u"_",
        u"－":u"-", u"＋":u"+", u"［":u"[", u"］":u"]", u"＜":u"<", u"＞":u">",
        u"？":u"?", u"，":u",", u"。":u".", u"／":u"/", u"、":u"," }

LIST_TEST={}
try:
    LIST_TEST=eval( os.getenv("CHSDIR") )
    LIST_TEST.keys()
except:
    LIST_TEST={}

def getPYSTR(s):
    try: s=unicode(s,"UTF8")
    except: s = s

    ret = ""
    for i in range(len(s)):
        uchr = LIST_CHARS.get(s[i],s[i])
        if uchr == s[i] :
            uchr = LIST_POLYPHONE.get(uchr,uchr)
            if len(uchr) > 1 :
                uchr = u"`%s`"%uchr
            else:
                uchr = getPY(uchr)
                if uchr != s[i]:
                    uchr = LIST_TEST.get(uchr,uchr)
        ret += uchr
    return ret.encode("UTF8")


def getPY(s):
    try: chr=s.encode("GB18030")
    except: return s
    if chr<"\xb0\xa1": return s
    if chr>"\xd7\xf9": return u"?"
    if chr<"\xb0\xc5": return u"a"
    if chr<"\xb2\xc1": return u"b"
    if chr<"\xb4\xee": return u"c"
    if chr<"\xb6\xea": return u"d"
    if chr<"\xb7\xa2": return u"e"
    if chr<"\xb8\xc1": return u"f"
    if chr<"\xb9\xfe": return u"g"
    if chr<"\xbb\xf7": return u"h"
    if chr<"\xbf\xa6": return u"j"
    if chr<"\xc0\xac": return u"k"
    if chr<"\xc2\xe8": return u"l"
    if chr<"\xc4\xc3": return u"m"
    if chr<"\xc5\xb6": return u"n"
    if chr<"\xc5\xbe": return u"o"
    if chr<"\xc6\xda": return u"p"
    if chr<"\xc8\xbb": return u"q"
    if chr<"\xc8\xf6": return u"r"
    if chr<"\xcb\xfa": return u"s"
    if chr<"\xcd\xda": return u"t"
    if chr<"\xce\xf4": return u"w"
    if chr<"\xd1\xb9": return u"x"
    if chr<"\xd4\xd1": return u"y"
    if chr<"\xd7\xfa": return u"z"
    return s

def chs_match(_name,path):
    _name_py= getPYSTR(_name).replace("\\","")
    _file_py = getPYSTR(path).replace("\\","")

    if path == _file_py : return (False,path)

    i=0;j=0;
    while len(_name_py) > i and len(_file_py) > j :
        if _file_py[j] == "`" and _name_py[i] != "`":
            end = _file_py.index("`",j+1)
            if _file_py.find( _name_py[i], j, end ) > 0 :
                i+=1; j=end+1
                continue
        else:
            if _name_py[i] == _file_py[j] or  _file_py[i] == "?":
                i+=1; j+=1
                continue;
        if _name_py[i]!=path[i] : break
    if len(_name_py) == i:
        try: path=unicode(path,"UTF8")
        except: path=path
        return (True,path[i:])
    else:
        return (False,path)


if __name__ == "__main__":
    print chs_match("sj","数据测试组")
