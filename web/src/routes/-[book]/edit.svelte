<script context="module" lang="ts">
  import { page } from '$app/stores'

  export async function load({ stuff }) {
    return { props: stuff }
  }
</script>

<script lang="ts">
  import { MainApp, BarItem } from '$gui'
  import NvinfoForm, { Params } from '$gui/parts/nvinfo/NvinfoForm.svelte'
  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo
</script>

<MainApp>
  <svelte:fragment slot="header-left">
    <BarItem this="span" icon="pencil" text="Sửa nội dung" show="tm" />
  </svelte:fragment>
  <NvinfoForm params={new Params(nvinfo)} />
</MainApp>
