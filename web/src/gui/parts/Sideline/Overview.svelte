<script context="module" lang="ts">
  import type { Rdpage, Rdline } from '$lib/reader'
</script>

<script lang="ts">
  import Wpanel from '$gui/molds/Wpanel.svelte'

  export let rpage: Rdpage
  export let rline: Rdline
</script>

<Wpanel title="Tiếng Trung" class="_zh _lg" --lc="2" wdata={rline.ztext}>
  {#if rline.ztext}{@html rline.ztext_html}{/if}
  <p slot="empty">Chưa có tiếng trung!</p>
</Wpanel>

<Wpanel title="Dịch máy mới:" class="cdata" --lc="5" wdata={rline.mt_ai_text}>
  {#if rline.mt_ai}{@html rline.mt_ai_html}{/if}
  <div slot="empty">Chưa có kết quả dịch máy</div>
</Wpanel>

<Wpanel title="Dịch thủ công:" class="_vi" --lc="4" wdata={rline.vtran}>
  {#if rline.vtran}{rline.vtran}{/if}
  <div slot="empty">
    <em>Chưa có kết quả dịch sẵn.</em>
    <button class="m-btn _xs _primary">Đóng góp!</button>
  </div>
</Wpanel>

<Wpanel
  class="_sm"
  title="Dịch bằng Google:"
  loader={rline.load_gtran.bind(rline)} />

<Wpanel
  title="Dịch bằng Bing:"
  class="_sm"
  wdata={rline.bt_zv}
  loader={rline.load_bt_zv.bind(rline)} />

<Wpanel
  title="Dịch bằng Baidu:"
  class="_sm"
  wdata={rline.baidu}
  loader={rline.load_baidu.bind(rline)} />

<Wpanel
  title="GPT Tiên hiệp:"
  class="_sm"
  wdata={rline.c_gpt}
  loader={rline.load_c_gpt.bind(rline)} />

<Wpanel title="Dịch máy cũ:" class="_sm" --lc="3" wdata={rline.qt_v1}>
  {#if rline.qt_v1}{rline.qt_v1}{/if}
  <em slot="empty">Chưa có kết quả dịch sẵn.</em>
</Wpanel>
