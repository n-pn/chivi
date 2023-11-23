<script lang="ts">
  import type { Writable } from 'svelte/store'

  import Config from './Homecp/Config.svelte'
  import Rdmemo from './Homecp/Rdmemo.svelte'

  // export let _user: Writable<App.CurrentUser>
</script>

<Rdmemo />
<Config />

<details open>
  <summary>Liên kết cá nhân</summary>
</details>
