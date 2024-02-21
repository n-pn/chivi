<script lang="ts">
  import type { Rdline } from '$lib/reader'
  import Wpanel from '$gui/molds/Wpanel.svelte'
  import { gen_mt_ai_html } from '$lib/mt_data_2'

  export let rline: Rdline
  export let ropts: Partial<CV.Rdopts>

  let mtype = ropts.mt_rm || 'mtl_1'

  const load_qtran = (qkind: string) => {
    return async (rmode = 1) => {
      const qdata = await rline.load_qtran(rmode, qkind, ropts)
      if (typeof qdata == 'string') return qdata
      return gen_mt_ai_html(qdata, 2)
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
  loader={load_qtran(mtype)}>
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
  title="Dịch bằng Baidu:"
  class="_sm"
  wdata={rline.qtran_text('bd_zv')}
  loader={rline.text_get_fn('bd_zv', ropts)} />

<Wpanel
  title="GPT Tiên hiệp:"
  class="_sm"
  wdata={rline.qtran_text('c_gpt')}
  loader={rline.text_get_fn('c_gpt', ropts)} />

<Wpanel
  class="_sm"
  title="Dịch bằng Google:"
  wdata={rline.qtran_text('gg_zv')}
  loader={rline.text_get_fn('gg_zv', ropts)} />

<Wpanel
  title="Dịch bằng Bing:"
  class="_sm"
  wdata={rline.qtran_text('ms_zv')}
  loader={rline.text_get_fn('ms_zv', ropts)} />

<Wpanel
  title="Dịch máy cũ:"
  class="_sm"
  wdata={rline.qtran_text('qt_v1')}
  loader={rline.text_get_fn('qt_v1', ropts)} />
