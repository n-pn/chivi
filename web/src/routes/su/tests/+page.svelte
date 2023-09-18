<script lang="ts">
  const vtree: CV.Cvtree = JSON.parse(
    '["TOP",0,74,"",[["IP",0,74,"",[["IP",0,20,"",[["NP",0,10,"",[["CLP",1,1,"",[["M",1,1,"","块","khối",22]]],["NP",8,2,"",[["NN",8,2,"","石头","tảng đá",24]]],["CP",2,6,"",[["CP",2,6,"",[["IP",2,5,"",[["NP",2,2,"",[["NN",2,2,"","形状","hình dáng",14]]],["VP",4,3,"",[["VA",4,3,"","不规则","bất quy tắc",12]]]]],["DEC",7,1,"Hide","的","",22]]]]],["DT",0,1,"","那","kia",22]]],["NP",10,2,"",[["NN",10,2,"","表面","mặt ngoài",14]]],["VP",12,8,"",[["VV",12,2,"","遍布","phân bố",12],["NP",14,6,"",[["NP",19,1,"",[["NN",19,1,"","斑","đốm",24]]],["ADJP",18,1,"",[["JJ",18,1,"","银","bạc",22]]],["CP",14,4,"",[["CP",14,4,"",[["IP",14,3,"",[["VP",14,3,"",[["NP",14,2,"",[["NN",14,2,"","结晶","kết tinh",14]]],["VP",16,1,"",[["VV",16,1,"","化","hoá",12]]]]]]],["DEC",17,1,"Hide","的","",22]]]]]]]]]]],["PU",20,1,"Capx Undb","，",",",22],["IP",21,18,"",[["VP",21,18,"",[["PP",21,8,"",[["P",21,1,"","在","ở",22],["NP",22,7,"",[["NP",27,2,"Ndes Nloc",[["NN",27,2,"Ndes Nloc","手中","trong tay",24]]],["NP",22,5,"",[["NN",25,2,"Npos Nper","小姐","tiểu thư",24],["NN",24,1,"","官","quan",14],["NN",22,2,"","舰务","hạm vụ",5]]]]]]],["VP",29,10,"",[["AS",31,1,"Hide","着","",22],["VV",29,2,"","散发","phát ra",12],["NP",32,7,"",[["NP",35,4,"",[["NN",37,2,"","光泽","sáng bóng",24],["NN",35,2,"Ndes","金属","kim loại",24]]],["CP",32,3,"",[["CP",32,3,"",[["IP",32,2,"",[["VP",32,2,"",[["VA",32,2,"","绚丽","huyễn lệ",12]]]]],["DEC",34,1,"Hide","的","",22]]]]]]]]]]]]],["PU",39,1,"Capx Undb","，",",",22],["IP",40,33,"",[["NP",40,4,"",[["PN",42,2,"","自己","bản thân",22],["NP",40,2,"Npos Nper",[["NR",40,2,"Npos Nper","方鸻","Phương Hằng",11]]]]],["VP",44,29,"",[["VP",44,12,"",[["ADVP",44,1,"",[["AD",44,1,"","就","liền",22]]],["VP",45,11,"",[["AS",47,1,"","过","qua",22],["VV",45,2,"","进修","tiến tu",12],["NP",48,8,"",[["NP",53,3,"",[["NN",55,1,"","学","học",24],["NN",53,2,"","矿物","khoáng vật",14]]],["DNP",48,5,"",[["DEG",52,1,"","的","của",25],["NP",48,4,"Npos Nloc",[["NR",48,4,"Npos Nloc","艾塔黎亚","Etariya",11]]]]]]]]]]],["PU",56,1,"Capx Undb","，",",",22],["VP",57,16,"",[["ADVP",57,2,"",[["AD",57,2,"","自然","tự nhiên",24]]],["ADVP",59,2,"",[["AD",59,2,"","一眼","một mắt",22]]],["VP",61,12,"",[["VV",61,2,"","认出","nhận ra",12],["IP",63,10,"",[["NP",63,1,"Pn_d",[["PN",63,1,"Pn_d","这","đây",22]]],["VP",64,9,"",[["VC",64,1,"","是","là",22],["NP",65,8,"",[["NP",67,6,"",[["NP",71,2,"",[["NN",71,2,"","矿物","khoáng vật",14]]],["NP",67,4,"",[["NN",70,1,"","银","bạc",24],["ADJP",69,1,"",[["JJ",69,1,"","秘","bí",12]]],["NN",67,2,"","硫化","lưu hoá",14]]]]],["DP",65,2,"Pn_d",[["DT",65,2,"Pn_d","某种","nào đó",14]]]]]]]]]]]]]]]]],["PU",73,1,"Capn Undb","。",".",22]]]]]'
  )

  let zfrom = 0
  let zupto = 1
  let icpos = 'DT'

  import { gen_ctree_html, gen_vtran_html } from '$lib/mt_data_2'

  import VitermForm from '$gui/parts/VitermForm.svelte'
</script>

<article class="article island">
  <h3 class="label">Tiếng Việt:</h3>

  <div class="cdata debug _hv">
    {@html gen_vtran_html(vtree, { mode: 2, cap: true, und: true })}
  </div>

  <h3 class="label">Cây ngữ pháp:</h3>

  <div class="cdata debug _ct">
    {@html gen_ctree_html(vtree, true, 2)}
  </div>

  <br />
  <div class="input">
    <label
      >Từ vị trí: <input
        class="m-input"
        type="number"
        bind:value={zfrom} /></label>
    <label
      >Tới vị trí: <input
        class="m-input"
        type="number"
        bind:value={zupto} /></label>
    <label
      >Từ loại: <input class="m-input" type="text" bind:value={icpos} /></label>
  </div>
</article>

<style lang="scss">
  .label {
    display: flex;
    @include ftsize(md);
    // padding: 0 0.75rem;
    // font-weight: bold;
    line-height: 1rem;

    margin-top: 0.5rem;
    margin-bottom: 0.25rem;
  }

  .cdata {
    padding: 0.25rem 0.5rem;
    @include border($loc: top-bottom);
    @include bgcolor(tert);
    @include scroll;

    &._zh {
      $line: 1.5rem;
      line-height: $line;
      max-height: $line * 3 + 0.75rem;
      @include ftsize(lg);
    }

    &._hv {
      $line: 1.125rem;
      line-height: $line;
      max-height: $line * 4 + 0.75rem;
    }

    &._ct {
      $line: 1.25rem;
      line-height: $line;
      max-height: $line * 10 + 0.75rem;

      :global(x-z) {
        font-weight: 500;
      }
    }
  }

  .input {
    display: flex;
    gap: 0.75rem;

    > label {
      flex: 1;
    }

    input {
      width: 100%;
    }
  }
</style>
