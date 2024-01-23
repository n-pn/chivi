<script lang="ts">
  import { onMount } from 'svelte'
  import { Rdpage, Rdword } from '$lib/reader'
  import Vtform, { ctrl as vtform_ctrl } from '$gui/shared/vtform/Vtform.svelte'

  let ropts = {
    pdict: 'combine',
    rmode: 'mt',
    qt_rm: 'bd_zv',
    mt_rm: 'mtl_2',
    wn_id: 0,
  }

  let ztext =
    '“既然你现在魔道双修，或许可以利用你体内同时存在两套的､本该是水火不容的根基，做一些出人意料的事情。”'

  $: rpage = new Rdpage(ztext)

  const call_debug = async () => {
    await rpage.load_hviet(2)
    await rpage.load_mtran(2, ropts.mt_rm, ropts.pdict)
    vtform_ctrl.show(0)
  }

  const node_names = ['X-N', 'X-C', 'X-Z']

  let rword = new Rdword(1, 3, 'CS')

  function handle_click({ target }) {
    if (!node_names.includes(target.nodeName)) return
    rword = Rdword.from(target)
    vtform_ctrl.show(0)
  }

  onMount(() => {
    rpage = new Rdpage(ztext)

    rpage.lines[0].hviet = JSON.parse(
      '["​“","​Kí"," nhiên"," nhĩ"," hiện"," tại"," ma"," đạo"," song"," tu","​,"," hoặc"," hứa"," khả"," dĩ"," lợi"," dụng"," nhĩ"," thể"," nội"," đồng"," thời"," tồn"," tại"," lưỡng"," sáo"," đích","​,"," bản"," cai"," thị"," thuỷ"," hoả"," bất"," dung"," đích"," căn"," cơ","​,"," tố"," nhất"," ta"," xuất"," nhân"," ý"," liệu"," đích"," sự"," tình","​.","​”"]'
    )
    rpage.lines[0].mtran[ropts.mt_rm] = JSON.parse(
      '["TOP",[["IP",[["PU","“",0,1,"“","Capx Undn",2],["CP",[["ADVP",[["CS","既然",1,3,"như đã","",2]],1,3,"","",-1],["IP",[["NP",[["PN","你",3,4,"ngươi","Nper",2]],3,4,"","Nper",-1],["VP",[["NP",[["NT","现在",4,6,"hiện tại","Ntmp",2]],4,6,"","Ntmp",-1],["QP",[["NP",[["NN","魔道",6,8,"ma đạo","",2]],6,8,"","",-1],["QP",[["AD","双",8,9,"đôi","",2]],8,9,"","",-1]],6,9,"","",-1],["VP",[["VV","修",9,10,"tu","",2]],9,10,"","",-1]],4,10,"","",-1]],3,10,"","",-1]],1,10,"","",-1],["PU","，",10,11,",","Capx Undb",2],["VP",[["ADVP",[["AD","或许",11,13,"có lẽ","Vmod",2]],11,13,"","Vmod",-1],["VP",[["VP",[["VV","可以",13,15,"có thể","",2],["VP",[["VP",[["VP",[["VV","利用",15,17,"lợi dụng","",2],["NP",[["NP",[["NP",[["NP",[["NN","、",27,28,",","Capx Undb",14]],27,28,"","Capx Undb",-1],["CP",[["CP",[["IP",[["VP",[["NP",[["NN",[["NP",[["NN","体内",18,20,"trong cơ thể","Ndes Nloc",2]],18,20,"","Ndes Nloc",-1],["NP",[["PN","你",17,18,"ngươi","Nper",2]],17,18,"","Nper",-1]],17,20,"","Ndes Nloc",-1]],17,20,"","",-1],["VP",[["ADVP",[["AD","同时",20,22,"đồng thời","",2]],20,22,"","",-1],["VP",[["VRD",[["VV","存",22,23,"tồn","",2],["VR","在",23,24,"tại","Sufx",26]],22,24,"","",-1],["QP",[["CD","两",24,25,"hai","",2],["CLP",[["M","套",25,26,"bộ","",2]],25,26,"","",-1]],24,26,"","",-1]],22,26,"","",-1]],20,26,"","",-1]],17,26,"","",-1]],17,26,"","",-1],["DEC","的",26,27,"⛶","Hide",2]],17,27,"","",-1]],17,27,"","",-1]],17,28,"","Capx",-1]],17,28,"","",-1],["NP",[["NP",[["NN","根基",36,38,"căn cơ","",2]],36,38,"","",-1],["CP",[["CP",[["IP",[["VP",[["VP",[["VV","本该",28,30,"vốn nên","",4],["VP",[["VP",[["VC","是",30,31,"là","",2],["IP",[["NP",[["NN","水火",31,33,"nước lửa","",2]],31,33,"","",-1],["VP",[["VV","不容",33,35,"không để cho","",2]],33,35,"","",-1]],31,35,"","",-1]],30,35,"","",-1]],30,35,"","",-1]],28,35,"","",-1]],28,35,"","",-1]],28,35,"","",-1],["DEC","的",35,36,"⛶","Hide",2]],28,36,"","",-1]],28,36,"","",-1]],28,38,"","",-1]],17,38,"","",-1]],15,38,"","",-1]],15,38,"","",-1],["PU","，",38,39,",","Capx Undb",2],["VP",[["VP",[["VV","做",39,40,"làm","",2],["NP",[["NP",[["QP","一些",40,42,"một chút","",2],["NP",[["NN","事情",47,49,"sự tình","",2]],47,49,"","",-1],["CP",[["CP",[["IP",[["VP","出人意料",42,46,"ngoài dự đoán của mọi người","",2]],42,46,"","",-1],["DEC","的",46,47,"⛶","Hide",2]],42,47,"","",-1]],42,47,"","",-1]],40,49,"","",-1]],40,49,"","",-1]],39,49,"","",-1]],39,49,"","",-1]],15,49,"","",-1]],13,49,"","",-1]],13,49,"","",-1]],11,49,"","",-1],["PU","。",49,50,".","Capn Undb",2],["PU","”",50,51,"”","Capx Undb",2]],0,51,"","",-1]],0,51,"","",-1]'
    )
    // vtform_ctrl.show(0)
  })

  const on_vtform_close = async (changed = false) => {
    if (changed) await rpage.load_mtran(2, ropts.mt_rm, ropts.pdict)
  }
</script>

<article class="article island">
  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div class="preview" on:click={handle_click}>
    <div class="left">
      <h3 class="label">Tiếng Trung:</h3>
      <div class="input">
        <textarea
          name="input"
          id=""
          rows="5"
          class="m-input cdata _zh"
          bind:value={ztext} />
      </div>

      <h3 class="label">Tiếng Việt:</h3>

      <div class="cdata debug _hv">
        {#each rpage.lines as rline}
          {@html rline.mtran_html(ropts.mt_rm)}
        {/each}
      </div>

      <h3 class="label">Hán Việt:</h3>

      <div class="cdata debug _hv">
        {#each rpage.lines as rline}
          {@html rline.hviet_html}
        {/each}
      </div>
    </div>

    <div class="right">
      <h3 class="label">Cây ngữ pháp:</h3>

      <div class="cdata debug _ct">
        {#each rpage.lines as rline}
          {@html rline.ctree_html(ropts.mt_rm)}
        {/each}
      </div>
    </div>
  </div>

  <button class="m-btn _primary _fill" on:click={call_debug}>
    <span>Parse data!</span>
  </button>
</article>

{#if $vtform_ctrl.actived}
  <Vtform rline={rpage.lines[0]} {rword} {ropts} on_close={on_vtform_close} />
{/if}

<style lang="scss">
  .preview {
    display: flex;
    gap: 0.75rem;
    > * {
      flex: 1;
      height: 100%;
    }
  }

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
    @include border();
    @include bdradi;
    @include bgcolor(main);
    @include scroll;

    &._zh {
      $line: 1.5rem;
      line-height: $line;
      @include ftsize(lg);
    }

    &._hv {
      $line: 1.125rem;
      line-height: $line;
    }

    &._ct {
      $line: 1.25rem;
      line-height: $line;

      :global(x-z) {
        font-weight: 500;
      }
    }
  }

  .input {
    // display: flex;
    gap: 0.75rem;

    textarea {
      width: 100%;
    }
  }
</style>
