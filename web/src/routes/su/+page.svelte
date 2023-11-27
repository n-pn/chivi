<script lang="ts">
  import { get_user } from '$lib/stores'
  import AddDonation from '$gui/shared/usercp/Setting/AddDonation.svelte'
  const _user = get_user()
</script>

<article class="article island">
  <h1>Administrator</h1>

  <details open>
    <summary>Ghi nhận ủng hộ</summary>
    <AddDonation />
  </details>
</article>
