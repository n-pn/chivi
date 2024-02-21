<script lang="ts">
  import TsrepoList from '$gui/shared/tsrepo/TsrepoList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ repos, memos, pgidx, pgmax } = data.table)
</script>

<TsrepoList {repos} {memos} {pgidx} {pgmax} />
