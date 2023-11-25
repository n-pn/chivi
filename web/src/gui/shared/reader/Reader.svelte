<script context="module" lang="ts">
  import { page } from '$app/stores'
  import { Pager } from '$lib/pager'
</script>

<script lang="ts">
  import Section from '$gui/sects/Section.svelte'

  import Switch from './Switch.svelte'
  import Rerror from './Rerror.svelte'
  import Rdpage from './Rdpage.svelte'

  export let crepo: CV.Chrepo
  export let rdata: CV.Chpart
  export let ropts: CV.Rdopts

  $: pager = new Pager($page.url, { rm: 'qt', qt: 'qt_v1', mt: 'mtl_1' })

  // states:
  // - 0: no need to reload,
  // - 1: reload, keep focus
  // - 2: reload, clear vtran
  // - 3: reload hviet + vtran
  let state = 3

  const tabs = [
    { type: 'qt', href: '?rm=qt', icon: 'language', text: 'Dịch thô' },
    { type: 'mt', href: '?rm=mt', icon: 'bolt', text: 'Dịch máy ✨' },
  ]
</script>

<Section {tabs} _now={ropts.rmode}>
  <Switch {pager} {ropts} />

  {#if rdata.error}
    <Rerror {crepo} bind:rdata bind:state />
  {:else}
    <Rdpage {ropts} bind:rdata bind:state />
  {/if}
</Section>
