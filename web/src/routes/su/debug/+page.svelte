<script lang="ts">
  import {
    gen_ctree_html,
    gen_hviet_html,
    gen_mt_ai_html,
  } from '$lib/mt_data_2'

  import Vtform, {
    data as vtform_data,
    ctrl as vtform_ctrl,
  } from '$gui/shared/vtform/Vtform.svelte'

  let pdict = 'combine'
  let m_alg = 'mtl_1'

  $: ai_url = `/_ai/debug?pdict=${pdict}&m_alg=${m_alg}`
  $: hv_url = `/_ai/hviet?pdict=${pdict}&m_alg=${m_alg}`

  let ztext =
    '“既然你现在魔道双修，或许可以利用你体内同时存在两套的､本该是水火不容的根基，做一些出人意料的事情。”'

  // prettier-ignore
  let ctree : CV.Cvtree[] = [["TOP",0,51,"",[["IP",0,51,"",[["PU",0,1,"Capx Undn","“","“",2],["CP",1,9,"",[["ADVP",1,2,"",[["CS",1,2,"","既然","như đã",2]]],["IP",3,7,"",[["NP",3,1,"Nper",[["PN",3,1,"Nper","你","ngươi",2]]],["NP",4,2,"Ntmp",[["NT",4,2,"Ntmp","现在","hiện tại",2]]],["NP",6,2,"",[["NN",6,2,"","魔道","ma đạo",2]]],["VP",8,2,"",[["VV",8,2,"","双修","song tu",2]]]]]]],["PU",10,1,"Capx Undb","，",",",2],["VP",11,38,"",[["ADVP",11,2,"Vmod",[["AD",11,2,"Vmod","或许","có lẽ",2]]],["VP",13,36,"",[["VP",13,36,"",[["VV",13,2,"","可以","có thể",2],["VP",15,34,"",[["VP",15,12,"",[["VV",15,2,"","利用","lợi dụng",2],["NP",17,10,"",[["NP",17,3,"",[["NP",17,3,"Ndes Nloc",[["PN",17,1,"Nper","你","ngươi",2],["NN",18,2,"Ndes Nloc","体内","trong cơ thể",2]]]]],["VP",20,7,"",[["ADVP",20,2,"",[["AD",20,2,"","同时","đồng thời",2]]],["VP",22,5,"",[["VRD",22,2,"",[["VV",22,1,"","存","tồn",2],["VR",23,1,"Sufx","在","tại",26]]],["NP",24,3,"",[["DNP",24,3,"",[["DEC",26,1,"Hide","的","⛶",2],["QP",24,2,"",[["CD",24,1,"","两","hai",2],["CLP",25,1,"",[["M",25,1,"","套","bộ",2]]]]]]]]]]]]]]]]],["PU",27,1,"Capx Undb","、",",",5],["VP",28,21,"",[["VP",28,21,"",[["VV",28,2,"","本该","vốn nên",4],["VP",30,19,"",[["VP",30,8,"",[["VC",30,1,"","是","là",2],["NP",31,7,"",[["NP",31,7,"",[["NP",36,2,"",[["NN",36,2,"","根基","căn cơ",2]]],["CP",31,5,"",[["CP",31,5,"",[["IP",31,4,"",[["VP",31,4,"","水火不容","thuỷ hoả bất dung",2]]],["DEC",35,1,"Hide","的","⛶",2]]]]]]]]]]],["PU",38,1,"Capx Undb","，",",",2],["VP",39,10,"",[["VV",39,1,"","做","làm",2],["NP",40,9,"",[["NP",40,9,"",[["QP",40,2,"","一些","một chút",2],["NP",47,2,"",[["NN",47,2,"","事情","sự tình",2]]],["CP",42,5,"",[["CP",42,5,"",[["IP",42,4,"",[["VP",42,4,"","出人意料","ngoài dự đoán của mọi người",2]]],["DEC",46,1,"Hide","的","⛶",2]]]]]]]]]]]]]]]]]]]]]]]]],["PU",49,1,"Capn Undb","。",".",2],["PU",50,1,"Capx Undb","”","”",2]]]]]]

  // prettier-ignore
  let hviet : [string,string][][] = [[["“","Capx Undn"],["kí",""],["nhiên",""],["nhĩ",""],["hiện",""],["tại",""],["ma",""],["đạo",""],["song",""],["tu",""],[",","Capx Undb"],["hoặc",""],["hứa",""],["khả",""],["dĩ",""],["lợi",""],["dụng",""],["nhĩ",""],["thể",""],["nội",""],["đồng",""],["thời",""],["tồn",""],["tại",""],["lưỡng",""],["sáo",""],["đích",""],[",","Capx Undb"],["bản",""],["cai",""],["thị",""],["thuỷ",""],["hoả",""],["bất",""],["dung",""],["đích",""],["căn",""],["cơ",""],[",","Capx Undb"],["tố",""],["nhất",""],["ta",""],["xuất",""],["nhân",""],["ý",""],["liệu",""],["đích",""],["sự",""],["tình",""],[".","Capn Undb"],["”","Capx Undb"]]]

  const call_debug = async () => {
    const rinit = { body: ztext, method: 'POST' }

    const hdata = await fetch(hv_url, rinit).then((r) => r.json())
    hviet = hdata.hviet

    const vdata = await fetch(ai_url, rinit).then((r) => r.json())
    ctree = vdata.lines

    console.log(vdata.ztree)
    navigator.clipboard.writeText(vdata.ztree[0])
  }

  const ropts: CV.Rdopts = {
    fpath: '',
    pdict,
    rmode: 'mt',
    mt_rm: m_alg,
    qt_rm: '',
    wn_id: 0,
  }

  const node_names = ['X-N', 'X-C', 'X-Z']

  let zfrom = 1
  let zupto = 3
  let icpos = 'CS'

  function handle_click({ target }) {
    if (!node_names.includes(target.nodeName)) return

    zfrom = +target.dataset.b
    zupto = +target.dataset.e

    const icpos = target.dataset.c || 'X'

    vtform_data.put(ztext, hviet[0], ctree[0], zfrom, zupto, icpos)
    vtform_ctrl.show(0)
  }

  $: vtform_data.put(ztext, hviet[0], ctree[0], zfrom, zupto, icpos)
  $: vtform_ctrl.show(0)
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
        {#each ctree as cdata}
          {@html gen_mt_ai_html(cdata, {
            mode: 2,
            cap: true,
            und: true,
            _qc: 0,
          })}
        {/each}
      </div>

      <h3 class="label">Hán Việt:</h3>

      <div class="cdata debug _hv">
        {#each hviet as hdata}
          {@html gen_hviet_html(hdata, true)}
        {/each}
      </div>
    </div>

    <div class="right">
      <h3 class="label">Cây ngữ pháp:</h3>

      <div class="cdata debug _ct">
        {#each ctree as cdata}
          {@html gen_ctree_html(cdata)}
        {/each}
      </div>
    </div>
  </div>

  <button class="m-btn _primary _fill" on:click={call_debug}>
    <span>Parse data!</span>
  </button>
</article>

{#if $vtform_ctrl.actived}
  <Vtform {ropts} />
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

    input,
    textarea {
      width: 100%;
    }
  }
</style>
