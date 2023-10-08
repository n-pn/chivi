<script lang="ts">
  import UpstemList from '$gui/parts/upstem/UpstemList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ items, pgidx, pgmax } = data.props)
</script>

<UpstemList {items} {pgidx} {pgmax} query={data.query} upath="/up/owned" />
