<script lang="ts">
  import type { Rdline } from '$lib/reader'
  import Wpanel from '$gui/molds/Wpanel.svelte'

  export let rline: Rdline
  export let ropts: CV.Rdopts

  let mtype = ropts.mt_rm || 'mtl_1'

  const load_qtran = (qtype: string) => {
    return async (rmode = 1) => {
      return await rline.load_qtran(rmode, qtype, ropts)
    }
  }

  const load_mtran = (mtype: string) => {
    return async (rmode = 1) => {
      await rline.load_mtran(rmode, mtype, ropts.pdict)
      return rline.mtran_html(mtype)
    }
  }
</script>

<Wpanel class="_zh _lg" title="Tiếng Trung" lines={2} wdata={rline.ztext}>
  {#if rline.ztext}{@html rline.ztext_html}{/if}
</Wpanel>

<Wpanel
  class="cdata"
  title="Dịch máy mới:"
  lines={5}
  wdata={rline.mtran_text(mtype)}
  loader={load_mtran(mtype)}>
  {@html rline.mtran_html(mtype)}
</Wpanel>

<!--
<Wpanel title="Dịch thủ công:" class="_vi" --lc="4" wdata={rline.vtran}>
  {#if rline.vtran}{rline.vtran}{/if}
  <div slot="empty">
    <em>Chưa có kết quả dịch sẵn.</em>
    <button class="m-btn _xs _primary">Đóng góp!</button>
  </div>
</Wpanel> -->

<Wpanel
  class="_sm"
  title="Dịch bằng Google:"
  wdata={rline.qtran['gg_zv']}
  loader={load_qtran('gg_zv')} />

<Wpanel
  title="Dịch bằng Bing:"
  class="_sm"
  wdata={rline.qtran['ms_zv']}
  loader={load_qtran('ms_zv')} />

<Wpanel
  title="Dịch bằng Baidu:"
  class="_sm"
  wdata={rline.qtran['bd_zv']}
  loader={load_qtran('bd_zv')} />

<Wpanel
  title="GPT Tiên hiệp:"
  class="_sm"
  wdata={rline.qtran['c_gpt']}
  loader={load_qtran('c_gpt')} />

<Wpanel
  title="Dịch máy cũ:"
  class="_sm"
  wdata={rline.qtran['qt_v1']}
  loader={load_qtran('qt_v1')} />
