<script context="module" lang="ts">
  import type { Rdpage, Rdline } from '$lib/reader'
  let states = { ztext: 1, mtran: 2, vtran: 2, bt_zv: 1, c_gpt: 1, qt_v1: 1 }
</script>

<script lang="ts">
  import { gen_ztext_html } from '$lib/mt_data_2'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Wpanel from '$gui/molds/Wpanel.svelte'

  export let rdpage: Rdpage
  export let rdline: Rdline

  let loading_bzv = false

  const load_bt_zv_data = async () => {
    loading_bzv = true
    await rdpage.load_bt_zv()
    rdpage = rdpage

    rdpage = await rdpage.load_bt_zv(2)
    loading_bzv = false
  }

  let loading_gpt = false

  const load_c_gpt_data = async () => {
    loading_gpt = true
    console.log('c_gpt')
    rdline = await rdline.load_c_gpt()

    loading_gpt = false
  }
</script>

<Wpanel
  title="Tiếng Trung"
  bind:state={states.ztext}
  class="_zh _lg"
  --lc="2"
  wdata={rdline.ztext}>
  {#if rdline.ztext}{@html rdline.ztext_html}{/if}
  <p slot="empty">Chưa có tiếng trung!</p>
</Wpanel>

<Wpanel
  title="Dịch máy mới:"
  bind:state={states.mtran}
  class="cdata"
  --lc="5"
  wdata={rdline.mt_ai_text}>
  {#if rdline.mt_ai}{@html rdline.mt_ai_html}{/if}
  <div slot="empty">Chưa có kết quả dịch máy</div>
</Wpanel>

<Wpanel
  title="Dịch thủ công:"
  bind:state={states.vtran}
  class="_vi"
  --lc="4"
  wdata={rdline.vtran}>
  {#if rdline.vtran} {rdline.vtran} {/if}
  <div slot="empty">
    <em>Chưa có kết quả dịch sẵn.</em>
    <button class="m-btn _xs _primary">Đóng góp!</button>
  </div>
</Wpanel>

<Wpanel
  title="Dịch bằng Bing:"
  bind:state={states.bt_zv}
  class="_sm"
  --lc="3"
  wdata={rdline.bt_zv}>
  {#if rdline.bt_zv}{rdline.bt_zv}{/if}
  <div slot="empty">
    <em>Chưa có kết quả dịch sẵn.</em>
    <button class="m-btn _xs _primary" on:click={load_bt_zv_data}>
      {#if loading_bzv}<SIcon name="loader-2" spin={true} />{/if}
      <span>Dịch bằng Bing!</span>
    </button>
  </div>
</Wpanel>

<Wpanel
  title="GPT Tiên hiệp:"
  bind:state={states.c_gpt}
  class="_sm"
  --lc="3"
  wdata={rdline.c_gpt}>
  {#if rdline.c_gpt}{rdline.c_gpt}{/if}
  <div slot="empty">
    <em>Chưa có kết quả dịch sẵn.</em>
    <button class="m-btn _xs _primary" on:click={load_c_gpt_data}>
      {#if loading_gpt}<SIcon name="loader-2" spin={true} />{/if}
      <span>Gọi công cụ!</span>
    </button>
  </div>
</Wpanel>

<Wpanel
  title="Dịch máy cũ:"
  bind:state={states.qt_v1}
  class="_sm"
  --lc="3"
  wdata={rdline.qt_v1}>
  {#if rdline.qt_v1}{rdline.qt_v1}{/if}
  <em slot="empty">Chưa có kết quả dịch sẵn.</em>
</Wpanel>
